*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.Desktop
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs
Library             Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
Order robots and consolidate to PDF.
    Open Website
    Download Orders
    Click on Ok
    Read Spreadsheet
    Create Zip file


*** Keywords ***
Open Website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download Orders
    ${url}=    Get Secret    URL

    Download    ${url}[downloadUrl]    overwrite=True

Click on Section

Click on Ok
    Wait Until Element Is Visible    class:btn-dark
    Click Button    class:btn-dark

Read Spreadsheet
    ${robot_orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{robot_orders}
        Order one robot    ${order}
        Click on Order
        Save Order as Pdf and Append Screenshot
        Click on Order another
    END

Order one robot
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    id:preview
    Wait Until Page Contains Element    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot.png

Click on Order
    Click Button    id:order
    ${error}=    Is Element Visible    class:alert-danger
    IF    ${error} == True
        Wait Until Keyword Succeeds    5x    1 sec    Click on Order
    ELSE
        Log    Error
    END

Save Order as Pdf and Append Screenshot
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:order-completion    outerHTML
    ${receipt}=    Get Text    class:badge-success
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts/${receipt}.pdf
    Open Pdf    ${OUTPUT_DIR}${/}receipts/${receipt}.pdf
    ${screenshot}=    Create List    ${OUTPUT_DIR}${/}robot.png
    Add Files To Pdf    ${screenshot}    ${OUTPUT_DIR}${/}receipts/${receipt}.pdf    append=True
    Close Pdf

Click on Order another
    Click Button    id:order-another
    Wait Until Element Is Visible    class:btn-dark
    Click Button    class:btn-dark

Create Zip file
    ${file_name}=    Get Value From User    Input file_name
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${file_name}.zip
