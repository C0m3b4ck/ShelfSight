#include "isbnscannerdialog.h"
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QComboBox>
#include <QCheckBox>
#include <QTextEdit>
#include <QLineEdit>
#include <QMessageBox>
#include <QTimer>
#include <QKeyEvent>
#include <QRegularExpression>
#include <QDebug>

#if HAS_CAMERA_SUPPORT
#include <QCamera>
#include <QMediaCaptureSession>
#include <QVideoWidget>
#include <QMediaDevices>
#endif

ISBNScannerDialog::ISBNScannerDialog(QWidget* parent)
    : QDialog(parent)
{
    setWindowTitle(tr("ISBN Scanner"));
    resize(600, 500);
    setupUI();
    setupCamera();
    
    // USB scanner timer - collects keystrokes within 100ms
    m_usbTimer = new QTimer(this);
    m_usbTimer->setSingleShot(true);
    m_usbTimer->setInterval(100);
    connect(m_usbTimer, &QTimer::timeout, this, &ISBNScannerDialog::onUSBScannerTimeout);
}

ISBNScannerDialog::~ISBNScannerDialog()
{
    onStopCamera();
}

void ISBNScannerDialog::setupUI()
{
    auto* mainLayout = new QVBoxLayout(this);
    
    // Camera selector
    auto* cameraLayout = new QHBoxLayout();
    cameraLayout->addWidget(new QLabel(tr("Camera:"), this));
    m_cameraSelector = new QComboBox(this);
    
#if HAS_CAMERA_SUPPORT
    const auto cameras = QMediaDevices::videoInputs();
    for (const auto& camera : cameras) {
        m_cameraSelector->addItem(camera.description(), camera.id());
    }
    if (cameras.isEmpty()) {
        m_cameraSelector->addItem(tr("No camera found"), "");
        m_cameraSelector->setEnabled(false);
    }
#else
    m_cameraSelector->addItem(tr("Camera support not available (Qt Multimedia not installed)"), "");
    m_cameraSelector->setEnabled(false);
#endif
    
    connect(m_cameraSelector, QOverload<int>::of(&QComboBox::currentIndexChanged), this, &ISBNScannerDialog::onCameraSelected);
    cameraLayout->addWidget(m_cameraSelector);
    
    m_btnStartCamera = new QPushButton(tr("Start Camera"), this);
    connect(m_btnStartCamera, &QPushButton::clicked, this, &ISBNScannerDialog::onStartCamera);
    cameraLayout->addWidget(m_btnStartCamera);
    
    m_btnStopCamera = new QPushButton(tr("Stop Camera"), this);
    m_btnStopCamera->setEnabled(false);
    connect(m_btnStopCamera, &QPushButton::clicked, this, &ISBNScannerDialog::onStopCamera);
    cameraLayout->addWidget(m_btnStopCamera);
    
    mainLayout->addLayout(cameraLayout);
    
#if HAS_CAMERA_SUPPORT
    // Video widget for camera preview
    m_videoWidget = new QVideoWidget(this);
    m_videoWidget->setMinimumHeight(300);
    m_videoWidget->setStyleSheet("background-color: black;");
    mainLayout->addWidget(m_videoWidget);
#else
    // Placeholder when camera not available
    QLabel* placeholder = new QLabel(tr("Camera scanning requires Qt6 Multimedia module.\nUSB barcode scanner input is still available."), this);
    placeholder->setAlignment(Qt::AlignCenter);
    placeholder->setStyleSheet("color: gray; background-color: #f0f0f0; border: 1px dashed gray;");
    placeholder->setMinimumHeight(200);
    mainLayout->addWidget(placeholder);
#endif
    
    // Status label
    m_statusLabel = new QLabel(tr("Ready. Connect a USB barcode scanner or start camera."), this);
    m_statusLabel->setWordWrap(true);
    m_statusLabel->setStyleSheet("color: gray;");
    mainLayout->addWidget(m_statusLabel);
    
    // USB Scanner options
    auto* optionsLayout = new QHBoxLayout();
    m_chkUSBScanner = new QCheckBox(tr("Enable USB Barcode Scanner (keyboard emulation)"), this);
    m_chkUSBScanner->setChecked(true);
    m_chkUSBScanner->setToolTip(tr("Most USB barcode scanners act as keyboard input. Enable to capture scanned ISBNs."));
    optionsLayout->addWidget(m_chkUSBScanner);
    
    m_chkAutoClose = new QCheckBox(tr("Auto-close on successful scan"), this);
    m_chkAutoClose->setChecked(true);
    optionsLayout->addWidget(m_chkAutoClose);
    optionsLayout->addStretch();
    mainLayout->addLayout(optionsLayout);
    
    // Manual ISBN entry
    auto* manualLayout = new QHBoxLayout();
    manualLayout->addWidget(new QLabel(tr("Manual ISBN:"), this));
    m_manualISBN = new QLineEdit(this);
    m_manualISBN->setPlaceholderText(tr("Enter ISBN-10 or ISBN-13 manually"));
    m_manualISBN->setClearButtonEnabled(true);
    connect(m_manualISBN, &QLineEdit::returnPressed, this, [this]() {
        processScannedText(m_manualISBN->text());
    });
    manualLayout->addWidget(m_manualISBN);
    mainLayout->addLayout(manualLayout);
    
    // Result display
    m_resultText = new QTextEdit(this);
    m_resultText->setReadOnly(true);
    m_resultText->setMaximumHeight(100);
    m_resultText->setPlaceholderText(tr("Scanned ISBN will appear here..."));
    mainLayout->addWidget(m_resultText);
    
    // Buttons
    auto* btnLayout = new QHBoxLayout();
    btnLayout->addStretch();
    
    m_btnClose = new QPushButton(tr("Close"), this);
    connect(m_btnClose, &QPushButton::clicked, this, &QDialog::reject);
    btnLayout->addWidget(m_btnClose);
    
    auto* btnUse = new QPushButton(tr("Use ISBN"), this);
    btnUse->setDefault(true);
    connect(btnUse, &QPushButton::clicked, this, [this]() {
        if (m_isValidISBN) {
            accept();
        } else {
            QMessageBox::warning(this, tr("Invalid ISBN"), tr("Please scan or enter a valid ISBN-10 or ISBN-13."));
        }
    });
    btnLayout->addWidget(btnUse);
    
    mainLayout->addLayout(btnLayout);
}

void ISBNScannerDialog::setupCamera()
{
#if HAS_CAMERA_SUPPORT
    m_captureSession = new QMediaCaptureSession(this);
    m_frameTimer = new QTimer(this);
    m_frameTimer->setInterval(500);
    connect(m_frameTimer, &QTimer::timeout, this, &ISBNScannerDialog::onCameraFrameReady);
#else
    // Disable camera buttons when multimedia not available
    m_btnStartCamera->setEnabled(false);
    m_btnStopCamera->setEnabled(false);
#endif
}

void ISBNScannerDialog::onStartCamera()
{
#if HAS_CAMERA_SUPPORT
    if (m_camera) {
        onStopCamera();
    }
    
    const auto cameraId = m_cameraSelector->currentData().toString();
    if (cameraId.isEmpty()) {
        QMessageBox::warning(this, tr("No Camera"), tr("No camera selected or available."));
        return;
    }
    
    m_camera = new QCamera(QMediaDevices::videoInputs().at(m_cameraSelector->currentIndex()), this);
    m_captureSession->setCamera(m_camera);
    m_captureSession->setVideoOutput(m_videoWidget);
    
    m_videoWidget->setVisible(true);
    m_camera->start();
    
    m_frameTimer->start();
    
    m_btnStartCamera->setEnabled(false);
    m_btnStopCamera->setEnabled(true);
    m_statusLabel->setText(tr("Camera started. Point at ISBN barcode..."));
    m_statusLabel->setStyleSheet("color: blue;");
    
    // Note: Real barcode decoding would require ZXing or similar library
    m_statusLabel->setText(tr("Camera active. For barcode decoding, install ZXing library.\nUSB scanner input is active."));
#else
    QMessageBox::information(this, tr("Not Available"), tr("Camera support requires Qt6 Multimedia module."));
#endif
}

void ISBNScannerDialog::onStopCamera()
{
#if HAS_CAMERA_SUPPORT
    if (m_camera) {
        m_camera->stop();
        m_frameTimer->stop();
        m_videoWidget->setVisible(false);
        delete m_camera;
        m_camera = nullptr;
    }
    
    m_btnStartCamera->setEnabled(true);
    m_btnStopCamera->setEnabled(false);
    m_statusLabel->setText(tr("Camera stopped. USB scanner input active."));
    m_statusLabel->setStyleSheet("color: gray;");
#else
    // Nothing to do
#endif
}

void ISBNScannerDialog::onCameraSelected(int index)
{
    Q_UNUSED(index);
#if HAS_CAMERA_SUPPORT
    if (m_camera && m_camera->isActive()) {
        onStopCamera();
    }
#endif
}

void ISBNScannerDialog::onCameraFrameReady()
{
#if HAS_CAMERA_SUPPORT
    // In a real implementation, this would:
    // 1. Grab frame from camera
    // 2. Convert to QImage
    // 3. Pass to ZXing decoder
    // 4. Process results
    
    // For now, this is a placeholder for when ZXing is integrated
#else
    // Not available
#endif
}

void ISBNScannerDialog::onUSBScannerTimeout()
{
    // Process accumulated USB scanner input
    if (!m_usbBuffer.isEmpty()) {
        QString scanned = m_usbBuffer.trimmed();
        m_usbBuffer.clear();
        processScannedText(scanned);
    }
}

void ISBNScannerDialog::keyPressEvent(QKeyEvent* event)
{
    if (m_usbScannerMode && m_chkUSBScanner->isChecked()) {
        // USB barcode scanners typically send the code followed by Enter
        if (event->key() == Qt::Key_Return || event->key() == Qt::Key_Enter) {
            m_usbTimer->stop();
            onUSBScannerTimeout();
        } else if (event->text().length() == 1 && event->text().at(0).isPrint()) {
            m_usbBuffer += event->text();
            m_usbTimer->start(); // Restart timer
        }
        // Don't call base - we're capturing the input
        return;
    }
    QDialog::keyPressEvent(event);
}

void ISBNScannerDialog::processScannedText(const QString& text)
{
    QString cleaned = cleanISBN(text);
    
    if (validateISBN(cleaned)) {
        m_scannedISBN = cleaned;
        m_isValidISBN = true;
        m_resultText->setPlainText(tr("✓ Valid ISBN found: %1").arg(m_scannedISBN));
        m_resultText->setStyleSheet("color: green; font-weight: bold;");
        m_statusLabel->setText(tr("Valid ISBN detected!"));
        m_statusLabel->setStyleSheet("color: green;");
        
        emit isbnScanned(m_scannedISBN);
        
        if (m_chkAutoClose->isChecked()) {
            accept();
        }
    } else {
        m_resultText->setPlainText(tr("✗ Invalid ISBN format: %1\nExpected ISBN-10 or ISBN-13").arg(text));
        m_resultText->setStyleSheet("color: red;");
        m_statusLabel->setText(tr("Invalid ISBN format. Try again."));
        m_statusLabel->setStyleSheet("color: red;");
    }
}

bool ISBNScannerDialog::validateISBN(const QString& isbn)
{
    // ISBN-10: 10 digits (last can be X)
    // ISBN-13: 13 digits
    QRegularExpression isbn10("^\\d{9}[\\dXx]$");
    QRegularExpression isbn13("^\\d{13}$");
    
    return isbn10.match(isbn).hasMatch() || isbn13.match(isbn).hasMatch();
}

QString ISBNScannerDialog::cleanISBN(const QString& raw)
{
    // Remove hyphens, spaces, and other non-alphanumeric chars except X
    QString cleaned = raw;
    cleaned.remove(QRegularExpression("[^\\dXx]"));
    return cleaned.toUpper();
}

