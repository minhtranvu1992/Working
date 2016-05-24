@echo off
set /p FOL=Enter your task number:
echo Completed create structure for %FOL%
md %FOL%
md %FOL%\A___Backup
md %FOL%\A___Backup\Script
md %FOL%\A___Backup\report
md %FOL%\B___Deploy
md %FOL%\B___Deploy\script
md %FOL%\B___Deploy\report
md %FOL%\B___Deploy\Attachments
md %FOL%\C___Document
md %FOL%\D___Develop



