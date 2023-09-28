// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;


contract InvestorInformation{
    uint256 InvestorId;
    constructor() {
        InvestorId = 0;
    }

    mapping (address => bool) isInserted;
    mapping (address => InvestorInfoStruct) InvestorInfo;
    struct InvestorInfoStruct{
        uint256 InvestorId;
        address InvestorAddress;
        string username;
        string email;
        string phoneNumber;
        string secretKey;
    }
    event InvestorInfoEvent(uint256 InvestorId, address InvestorAddress, string username, string email, string phoneNumber, string secretKey);


    function SaveInvestorInformation(address _investorAddress, string memory _username, string memory _email, string memory _phoneNumber, string memory _secretKey) public {
        require(msg.sender == _investorAddress, "Authentication Failed !!");
        require(isInserted[_investorAddress] == false, "Investor Information already stored on blockchain.");
        isInserted[_investorAddress] = true;
        InvestorId += 1;
        InvestorInfo[_investorAddress] = InvestorInfoStruct(InvestorId, _investorAddress, _username, _email, _phoneNumber, _secretKey);
        emit InvestorInfoEvent(InvestorId, _investorAddress, _username, _email, _phoneNumber, _secretKey);
    }

    function GetInvestorInformation(address _investorAddress) public view returns(InvestorInfoStruct memory){
        require(msg.sender == _investorAddress, "Authentication Failed !!");
        InvestorInfoStruct memory getInvestorData = InvestorInfo[_investorAddress];
        return getInvestorData;
    } 
}