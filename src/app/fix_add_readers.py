#!/usr/bin/env python3
"""Fix remaining widget references and missing implementations"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Fix Add Readers page (page_10) widget references
replacements = {
    # on_btnAdd_reader_clicked - use _addreaders suffix
    'ui->txtName_reader->text()': 'ui->txtName_addreaders->text()',
    'ui->txtSurname_reader->text()': 'ui->txtSurname_addreaders->text()',
    'ui->txtGrade_reader->text()': 'ui->txtGrade_addreaders->text()',
    'ui->txtClass_reader->text()': 'ui->txtClass_addreaders->text()',
    'ui->txtId_reader->text()': 'ui->txtID_addreaders->text()',
    'ui->lstSearch_reader_edit->addItem': 'ui->lstSearch_reader_edit->addItem',
    'ui->txtName_reader->clear': 'ui->txtName_addreaders->clear',
    'ui->txtSurname_reader->clear': 'ui->txtSurname_addreaders->clear',
    'ui->txtGrade_reader->clear': 'ui->txtGrade_addreaders->clear',
    'ui->txtClass_reader->clear': 'ui->txtClass_addreaders->clear',
    'ui->txtId_reader->clear': 'ui->txtID_addreaders->clear',
    
    # Add missing implementations - add them after on_btnAdd_reader_clicked
    'void MainWindow::on_btnAdd_reader_clicked()': '''void MainWindow::on_btnAdd_reader_clicked()
{
    // check if DB is selected
    if (is_qstring_empty(database_readers) == true)
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    DTO::ReaderDTO reader;
    reader.name = toStd(ui->txtName_addreaders->text());
    reader.surname = toStd(ui->txtSurname_addreaders->text());
    reader.grade = ui->txtGrade_addreaders->text().toShort();
    reader.classGroup = ui->txtClass_addreaders->text().at(0).toLatin1();
    reader.studentId = toStd(ui->txtID_addreaders->text());
    reader.id = std::stoi(reader.studentId);
    reader.createdAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));
    reader.updatedAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.readers) {
        auto result = BusinessLogic::addReader(*facade.readers, reader);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    QString display = QString::fromStdString(reader.toDisplayString());

    // add to list widget for immediate feedback
    ui->lstSearch_reader_edit->addItem(display);

    // store for undo
    last_reader_added = reader;

    QMessageBox::information(this, tr("SUCCESS"), tr("Reader added"));

    // clear input fields
    ui->txtName_addreaders->clear();
    ui->txtSurname_addreaders->clear();
    ui->txtGrade_addreaders->clear();
    ui->txtClass_addreaders->clear();
    ui->txtID_addreaders->clear();
}''',

    # Add missing on_btnUndoAdd_addreaders_clicked
    'void MainWindow::on_btnUndoAdd_addreaders_clicked()': '''void MainWindow::on_btnUndoAdd_addreaders_clicked()
{
    if (is_reader_dto_empty(last_reader_added)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent add to undo"));
        return;
    }
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo add?"));
    box.setText(
        tr(
            "Are you sure you want to undo add reader:\\n"
            "Name: %1\\n"
            "Surname: %2\\n"
            "Grade: %3\\n"
            "Class: %4\\n"
            "ID: %5"
            )
            .arg(last_reader_added.name)
            .arg(last_reader_added.surname)
            .arg(last_reader_added.grade)
            .arg(last_reader_added.classGroup)
            .arg(last_reader_added.studentId));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove the added reader from list (frontend only)
        for (int i = 0; i < ui->lstSearch_reader_edit->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_reader_edit->item(i);
            if (item->text().contains(QString::fromStdString(last_reader_added.name)) && item->text().contains(QString::fromStdString(last_reader_added.surname)))
            {
                delete ui->lstSearch_reader_edit->takeItem(i);
                break;
            }
        }
        last_reader_added = DTO::ReaderDTO{};
        QMessageBox::information(this, tr("SUCCESS"), tr("Reader add undone (frontend only - requires DB implementation)"));
    }
}''',
}

for old, new in replacements.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        print(f"Fixed {count}x: {old[:50]}... -> {new[:50]}...")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")