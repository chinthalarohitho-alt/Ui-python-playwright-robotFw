*** Settings ***
Library    Browser

*** Variables ***
${URL}                https://www.saucedemo.com/
${USERNAME_FIELD}     input[data-test="username"]
${PASSWORD_FIELD}     input[data-test="password"]
${LOGIN_BUTTON}       input[data-test="login-button"]
${SORT_DROPDOWN}      select[data-test="product-sort-container"]
${CART_ICON}          a[data-test="shopping-cart-link"]
${CHECKOUT_BTN}       button[data-test="checkout"]
${FIRST_NAME}         input[data-test="firstName"]
${LAST_NAME}          input[data-test="lastName"]
${POSTAL_CODE}        input[data-test="postalCode"]
${CONTINUE_BTN}       input[data-test="continue"]
${FINISH_BTN}         button[data-test="finish"]
${MENU_BTN}           button#react-burger-menu-btn
${LOGOUT_LINK}        a#logout_sidebar_link
${SUCCESS_HEADER}     .complete-header
${THANK_YOU_MSG}      Thank you for your order!

*** Keywords ***
Open Login Page
    New Browser    browser=chromium    headless=False
    New Page       ${URL}

Perform Login
    [Arguments]    ${username}    ${password}
    Type Text      ${USERNAME_FIELD}    ${username}
    Type Text      ${PASSWORD_FIELD}    ${password}
    Click          ${LOGIN_BUTTON}

Verify Login Success
    Get Text       .title    ==    Products
    Take Screenshot

Verify Login Error
    [Arguments]    ${expected_error}
    Get Text       h3[data-test="error"]    contains    ${expected_error}
    Take Screenshot

Sort Products By
    [Arguments]    ${option}
    Select Options By    ${SORT_DROPDOWN}    value    ${option}
    # verify first item text after sort if needed

Add Item To Cart
    [Arguments]    ${item_name}
    # Convert item name to data-test format (e.g., "Sauce Labs Backpack" -> "add-to-cart-sauce-labs-backpack")
    ${id}=    Evaluate    "${item_name}".lower().replace(" ", "-")
    Click    button[data-test="add-to-cart-${id}"]

Remove Item From Cart
    [Arguments]    ${item_name}
    ${id}=    Evaluate    "${item_name}".lower().replace(" ", "-")
    Click    button[data-test="remove-${id}"]

Proceed To Checkout
    Click    ${CART_ICON}
    Click    ${CHECKOUT_BTN}

Complete Checkout Information
    [Arguments]    ${first}    ${last}    ${zip}
    Fill Text      ${FIRST_NAME}    ${first}
    Fill Text      ${LAST_NAME}     ${last}
    Fill Text      ${POSTAL_CODE}    ${zip}
    Click          ${CONTINUE_BTN}

Finish Checkout
    Click          ${FINISH_BTN}
    Get Text       ${SUCCESS_HEADER}    ==    ${THANK_YOU_MSG}

Logout User
    Click    ${MENU_BTN}
    Click    ${LOGOUT_LINK}
    Wait For Elements State    ${LOGIN_BUTTON}    visible
