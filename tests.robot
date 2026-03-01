*** Settings ***
Resource          resource.robot
Test Setup        Open Login Page
Test Teardown     Close Browser

*** Test Cases ***
Successful Login with Valid Credentials
    [Tags]    smoke    positive
    Perform Login    standard_user    secret_sauce
    Verify Login Success

Invalid Login Scenarios
    [Tags]    regression    negative
    [Template]    Login With Invalid Credentials Should Fail
    # Username          # Password          # Expected Error
    invalid_user       secret_sauce        Epic sadface: Username and password do not match any user in this service
    standard_user      invalid_password    Epic sadface: Username and password do not match any user in this service
    ${EMPTY}           secret_sauce        Epic sadface: Username is required
    standard_user      ${EMPTY}            Epic sadface: Password is required

Product Sorting
    [Tags]    regression
    Perform Login    standard_user    secret_sauce
    Sort Products By    lohi
    Get Text    .inventory_item_price >> nth=0    ==    $7.99
    Sort Products By    hilo
    Get Text    .inventory_item_price >> nth=0    ==    $49.99

Manage Shopping Cart
    [Tags]    smoke
    Perform Login    standard_user    secret_sauce
    Add Item To Cart    Sauce Labs Backpack
    Get Text    .shopping_cart_badge    ==    1
    Remove Item From Cart    Sauce Labs Backpack
    Wait For Elements State    .shopping_cart_badge    hidden

Complete Purchase Flow
    [Tags]    smoke    critical
    Perform Login    standard_user    secret_sauce
    Add Item To Cart    Sauce Labs Bike Light
    Proceed To Checkout
    Complete Checkout Information    John    Doe    12345
    Finish Checkout

Logout Application
    [Tags]    smoke
    Perform Login    standard_user    secret_sauce
    Logout User

*** Keywords ***
Login With Invalid Credentials Should Fail
    [Arguments]    ${username}    ${password}    ${expected_error}
    Perform Login    ${username}    ${password}
    Verify Login Error    ${expected_error}
