// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.0;


contract HotelRoom {
    address payable public owner;
    enum Statuses { Vacant, Occupied }
    Statuses currentStatus;

    event Occupy(address _occupant, uint _value);

    constructor() public {
        owner = msg.sender;
        currentStatus = Statuses.Vacant;
    }


    modifier onlyWhileVacant {
        require(currentStatus == Statuses.Vacant , "Currently Occupied");
        _;
    }
    modifier cost(uint _amount) {
        require(msg.value >= _amount, "Not enough Ether Provided.");
        _;
    }

    receive() external payable onlyWhileVacant cost(2 ether){
        owner.transfer(msg.value);
        currentStatus = Statuses.Occupied;
        emit Occupy(msg.sender, msg.value);
    }
}