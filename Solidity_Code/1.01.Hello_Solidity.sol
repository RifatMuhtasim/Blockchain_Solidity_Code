// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract HelloWorld{
    string message;

    constructor(){
        message = "Hello Solidity";
    }

    function show_message() public view returns (string memory) {
        return message;
    }
}
