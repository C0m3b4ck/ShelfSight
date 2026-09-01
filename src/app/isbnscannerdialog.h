#pragma once

#include <QDialog>
#include <QTimer>
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QComboBox>
#include <QCheckBox>
#include <QTextEdit>
#include <QLineEdit>
#include <QKeyEvent>
#include <QRegularExpression>

// Check for Qt Multimedia availability
#ifdef QT_MULTIMEDIA_LIB
#define HAS_CAMERA_SUPPORT 1
#include <QCamera>
#include <QMediaCaptureSession>
#include <QVideoWidget>
#include <QMediaDevices>
#else
#define HAS_CAMERA_SUPPORT 0
#endif

class ISBNScannerDialog : public QDialog
{
    Q_OBJECT

public:
    explicit ISBNScannerDialog(QWidget* parent = nullptr);
    ~ISBNScannerDialog() override;

    QString getScannedISBN() const { return m_scannedISBN; }
    bool isISBNValid() const { return m_isValidISBN; }

    // For USB barcode scanner (keyboard emulation)
    void setUSBScannerMode(bool enabled) { m_usbScannerMode = enabled; }
    void keyPressEvent(QKeyEvent* event) override;

signals:
    void isbnScanned(const QString& isbn);

private slots:
    void onStartCamera();
    void onStopCamera();
    void onCameraFrameReady();
    void onUSBScannerTimeout();
    void onCameraSelected(int index);

private:
    void setupUI();
    void setupCamera();
    void processScannedText(const QString& text);
    bool validateISBN(const QString& isbn);
    QString cleanISBN(const QString& raw);

    QString m_scannedISBN;
    bool m_isValidISBN = false;
    bool m_usbScannerMode = true;
    QString m_usbBuffer;
    QTimer* m_usbTimer = nullptr;

#if HAS_CAMERA_SUPPORT
    // Camera components
    QCamera* m_camera = nullptr;
    QMediaCaptureSession* m_captureSession = nullptr;
    QVideoWidget* m_videoWidget = nullptr;
    QTimer* m_frameTimer = nullptr;
#endif

    // UI components
    QComboBox* m_cameraSelector = nullptr;
    QPushButton* m_btnStartCamera = nullptr;
    QPushButton* m_btnStopCamera = nullptr;
    QPushButton* m_btnClose = nullptr;
    QLabel* m_statusLabel = nullptr;
    QTextEdit* m_resultText = nullptr;
    QLineEdit* m_manualISBN = nullptr;
    QCheckBox* m_chkUSBScanner = nullptr;
    QCheckBox* m_chkAutoClose = nullptr;
};