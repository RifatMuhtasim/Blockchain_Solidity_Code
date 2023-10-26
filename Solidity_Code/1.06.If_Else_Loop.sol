// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.0;


contract IfElseNLoops{
    //1
    function isEvenNumber(uint _number) public view returns(bool) {
        if(_number % 2 == 0){
            return true;
        } else {
            return false;
        }
    }


    //2
    uint[] public numberList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,12, 14, 13];
    function checkOddNumber() public view returns(uint) {
        uint count = 0;

        for(uint i=0; i < numberList.length; i++){
            if(!isEvenNumber(numberList[i])){
                count ++;
            }
        }
        return count;
    }

    //3
    address public owner;
    constructor() public {
        owner = msg.sender;
    }

    function isOwner() public view returns(bool){
        return(msg.sender == owner);
    }
}