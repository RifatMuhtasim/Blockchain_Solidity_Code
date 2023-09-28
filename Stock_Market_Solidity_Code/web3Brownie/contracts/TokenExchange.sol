// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// this is IPO Token A1 Solidity code 

contract TokenTypeA1FixedPriceExchangeContract{
    uint companyId;
    uint companySecretKey;
    constructor() {
        companyId = 0;
        companySecretKey = 747;
    }

    
    struct companiesStruct{
        uint companyId;
        address payable companyAddress;
        string companyCode;
        string name;
        uint tokens;
        uint perTokenPrice;
        uint maximumAmountOfTokenOneCanBuy;
    }
    companiesStruct[] public companies;

    mapping(address => bool) public isCompany;
    event companiesEvent(uint companyId, address payable companyAddress, string companyCode, string name, uint tokens, uint perTokenPrice, uint maximumAmountOfTokenOneCanBuy);
    
    function AddCompany(address payable _companyAddress, string memory _companyCode, string memory _name, uint _tokens, uint _companySecretKey, uint _perTokenPrice, uint _maximumAmountOfTokenOneCanBuy) external {
        require(msg.sender == _companyAddress, "Authentication Failed !!");
        require(isCompany[_companyAddress] == false , "Company already exist ..");
        require(companySecretKey == _companySecretKey, "Secret Key is not matched ..");
    
        companies.push(companiesStruct(companyId, _companyAddress, _companyCode, _name, _tokens, _perTokenPrice, _maximumAmountOfTokenOneCanBuy ));
        isCompany[_companyAddress] = true;
        companyId += 1;
        emit companiesEvent(companyId, _companyAddress, _companyCode, _name, _tokens, _perTokenPrice, _maximumAmountOfTokenOneCanBuy);
    }

    function GetAllCompany() external view returns(companiesStruct[] memory){
        return companies;
    }


    // List of companies Investor 
    mapping(address => address[]) companyAllInvestorAddress;

    function GetCompanyAllInvestorLength(address _companyAddress) external view returns(uint){
        require(msg.sender == _companyAddress, "Authentication Failed !!");
        require(isCompany[_companyAddress] == true , "Company is not exist ..");
        return companyAllInvestorAddress[_companyAddress].length;
    }

    function GetCompanyAllInvestor(address _companyAddress, uint _id) external view returns(investorTokenInfoStruct memory){
        require(msg.sender == _companyAddress, "Authentication Failed !!");
        require(isCompany[_companyAddress] == true , "Company is not exist ..");
        return investorTokenInfo[companyAllInvestorAddress[_companyAddress][_id]][_companyAddress];
    }



    //Investor Center
    mapping(address => mapping(address => investorTokenInfoStruct)) investorTokenInfo;
    mapping(address => address[]) investorCurrentCompaniesList;
    mapping(address => mapping(address => bool)) isInvestorAlreadyListed;

    struct investorTokenInfoStruct{
        address payable investorAddress;
        address payable companyAddress;
        uint companyId;
        uint numberOfTokenPurchased;
        string companyName;
        string companyCode;
    }
    event investorTokenInfoEvent(address payable investorAddress, address payable companyAddress, uint companyId, uint numberOfTokenPurchased, string companyName, string companyCode);
    

    function InvestorPurchasedTokens(address payable _investorAddress, address payable _companyAddress, uint _companyId, uint _numberOfTokenPurchased, string memory _companyName, string memory _companyCode) external {
        require(msg.sender == _investorAddress, "Authentication Failed !!");
        companiesStruct storage getCompanyData = companies[_companyId];
        require(_numberOfTokenPurchased <= getCompanyData.maximumAmountOfTokenOneCanBuy, "You can not purchased a lot of Tokens");
        require(_numberOfTokenPurchased <= getCompanyData.tokens, "Available token is not valid.");
        
        getCompanyData.tokens = getCompanyData.tokens - _numberOfTokenPurchased;

        if(isInvestorAlreadyListed[_investorAddress][_companyAddress] == false) {
            investorTokenInfo[_investorAddress][_companyAddress] = investorTokenInfoStruct(_investorAddress, _companyAddress, _companyId, _numberOfTokenPurchased, _companyName, _companyCode);
            investorCurrentCompaniesList[_investorAddress].push(_companyAddress);

            isInvestorAlreadyListed[_investorAddress][_companyAddress] = true;
            companyAllInvestorAddress[_companyAddress].push(_investorAddress);
            emit investorTokenInfoEvent(_investorAddress, _companyAddress, _companyId, _numberOfTokenPurchased, _companyName, _companyCode);

        } else {
            investorTokenInfoStruct storage getInvestorData = investorTokenInfo[_investorAddress][_companyAddress];
            getInvestorData.numberOfTokenPurchased = getInvestorData.numberOfTokenPurchased + _numberOfTokenPurchased;
        }
    } 

    function GetInvestorCompaniesLength(address _investorAddress) external view returns (uint) {
        require(msg.sender == _investorAddress, "Authentication Failed !!");
        return investorCurrentCompaniesList[_investorAddress].length;
    }

    function GetInvestorCompany(address _investorAddress, uint _id) external view returns (investorTokenInfoStruct memory){
        require(msg.sender == _investorAddress, "Authentication Failed !!");
        address _companyAddress = investorCurrentCompaniesList[_investorAddress][_id];
        return investorTokenInfo[_investorAddress][_companyAddress];
    }



    // Exchange Token 
    function ExchangeTokens(address payable _fromInvestor, address payable _toInvestor, address payable _companyAddress, uint _numberOfTokenExchange) external {
        require(msg.sender == _fromInvestor, "Authentication Failed !!");

        investorTokenInfoStruct storage getSenderInvestorData = investorTokenInfo[_fromInvestor][_companyAddress];
        require(getSenderInvestorData.numberOfTokenPurchased >= _numberOfTokenExchange, "Number of Exchange token is not valid.");
        getSenderInvestorData.numberOfTokenPurchased -= _numberOfTokenExchange;


        if(isInvestorAlreadyListed[_toInvestor][_companyAddress] == false) {
            investorTokenInfo[_toInvestor][_companyAddress] = investorTokenInfoStruct(_toInvestor, _companyAddress, getSenderInvestorData.companyId, _numberOfTokenExchange, getSenderInvestorData.companyName, getSenderInvestorData.companyCode);
            investorCurrentCompaniesList[_toInvestor].push(_companyAddress);
            isInvestorAlreadyListed[_toInvestor][_companyAddress] = true;
 
            companyAllInvestorAddress[_companyAddress].push(_toInvestor);
            emit investorTokenInfoEvent(_toInvestor, _companyAddress, getSenderInvestorData.companyId, _numberOfTokenExchange, getSenderInvestorData.companyName, getSenderInvestorData.companyCode);

        } else {
            investorTokenInfoStruct storage getReceivedInvestorData = investorTokenInfo[_toInvestor][_companyAddress];
            getReceivedInvestorData.numberOfTokenPurchased += _numberOfTokenExchange;
            
        }
    }

}


