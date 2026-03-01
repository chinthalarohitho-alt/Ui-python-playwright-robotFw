*** Settings ***
Library    Browser
Library    String
Library    OperatingSystem    # Add this line
# Add a Suite Setup to clean logs before any tests run
Suite Setup       Remove Previous Logs

Test Setup        Open Conduit Application
Test Teardown     Close Browser

*** Variables ***
${BASE_URL}             https://conduit.bondaracademy.com/
${USER_EMAIL}           chinthalarohitho@gmail.com
${USER_PASSWORD}        Rohit144@
${ARTICLE_BODY}         This is a sample article body for automation testing.
${ARTICLE_DESCRIPTION}  Automating the Conduit app using Robot Framework and Playwright.
${TAGS}                 robotframework-playwright

*** Test Cases ***
Create And Delete An Article Successfully
    [Tags]    smoke    conduit
    
    # 1. Sign In (Only if not already logged in)
    ${is_logged_in}=    Get Element Count    text=New Article
    IF    ${is_logged_in} == 0
        Click    text=Sign in
        Wait For Condition    Url    contains    /login
        Fill Text    input[placeholder="Email"]       ${USER_EMAIL}
        Fill Text    input[placeholder="Password"]    ${USER_PASSWORD}
        Click    button:has-text("Sign in")
    END
    
    # Verify Login persistence
    Wait For Elements State    text=New Article    visible    timeout=10s
    
    # 2. Generate Random Article Title
    ${random_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    ${article_name}=     Set Variable    AI-Robot-Article-${random_suffix}
    Set Suite Variable    ${CURRENT_ARTICLE_NAME}    ${article_name}

    # 3. Create New Article
    Click    text=New Article
    Wait For Condition    Url    contains    /editor
    Fill Text    input[placeholder="Article Title"]    ${article_name}
    Fill Text    input[placeholder="What's this article about?"]    ${ARTICLE_DESCRIPTION}
    Focus        textarea
    Fill Text    textarea    ${ARTICLE_BODY}
    Fill Text    input[placeholder="Enter tags"]    ${TAGS}
    # Ensure the button is visible and click it
    Click    button:has-text("Publish Article")
    
    # Check for validation errors if redirection doesn't happen quickly
    Sleep    2s    # Short wait for any instant validation errors to appear
    ${error_count}=    Get Element Count    ul.error-messages li
    IF    ${error_count} > 0
        ${errors}=    Get Text    ul.error-messages
        Log    Validation Errors: ${errors}    level=ERROR
        Take Screenshot
        Fail    Article publication failed with errors: ${errors}
    END

    # 4. Assert Article Creation Correctness
    # Wait for the redirection to the article page
    Wait For Condition    Url    contains    /article/    timeout=15s
    
    # The title should be in the banner section
    Wait For Elements State    div.banner h1:has-text("${article_name}")    visible    timeout=10s
    Get Text    div.banner h1    ==    ${article_name}
    Take Screenshot
    
    # 5. Verify on Home Page (Global Feed)
    Click    text=Home
    # Wait for the feed to load
    Wait For Elements State    text=Global Feed    visible
    Click    text=Global Feed
    
    # Verify first article name matches the one we created
    # Note: Global feed might take a second to update, ensuring the specific article is visible
    Wait For Elements State    h1:has-text("${article_name}")    visible
    
    # 6. Delete Article
    Click    h1:has-text("${article_name}")
    Click    div.banner button:has-text("Delete Article")
    
    # 7. Final Verification
    Wait For Elements State    text=Your Feed    visible
    Get Url    ==    ${BASE_URL}

*** Keywords ***
Remove Previous Logs
    # This will delete any file starting with 'playwright-log' and ending in '.txt'
    # The True argument tells it to silently ignore if the files don't exist yet
    Remove Files    ${EXECDIR}/playwright-log*.txt
    
Open Conduit Application
    New Browser    browser=chromium    headless=False
    New Context    viewport={'width': 1280, 'height': 720}
    New Page       ${BASE_URL}
    Wait For Elements State    a.navbar-brand:has-text("conduit")    visible
