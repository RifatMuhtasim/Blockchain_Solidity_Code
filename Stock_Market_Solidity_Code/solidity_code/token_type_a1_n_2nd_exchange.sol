// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExchangeOnSecondary {
    mapping(address => uint256) public last_exchange_price; // last_exchange_price[_company_address]

    function last_ex_price(address _company_address) public view returns (uint256) {
        return last_exchange_price[_company_address];
    }

    address owner;

    constructor() payable {
        owner = msg.sender;
    }

    struct bid_buyer_session_storage_struct {
        address payable company_address;
        address payable investor_address;
        uint256 how_much_token_want_to_purchased;
        uint256 bid_buying_price;
    }
    mapping(address => mapping(uint256 => mapping(address => bid_buyer_session_storage_struct))) public bid_buyer_info; // bid_buyer_info[_company_address][_bid_buying_price][bid_buyer_address]
    mapping(address => mapping(uint256 => address[])) public array_of_bid_buyer_in_this_price_range; // array_of_bid_buyer_in_this_price_range[_company_address][_bid_buying_price][0]

    // Sell a token - Ask
    struct ask_seller_session_storage_struct {
        address payable company_address;
        address payable investor_address;
        uint256 how_much_token_want_to_sell;
        uint256 ask_selling_price;
    }
    mapping(address => mapping(uint256 => mapping(address => ask_seller_session_storage_struct))) public ask_seller_info; // ask_seller_info[_company_address][_ask_selling_price][_ask_seller_address]
    mapping(address => mapping(uint256 => address[])) array_of_ask_seller_in_this_price_range; // array_of_ask_seller_in_this_price_range[_company_address][_ask_seller_price][0]

    mapping(address => uint256) public lowest_asking_price; // lowest_asking_price[_company_address]
    mapping(address => uint256) public highest_asking_price; // highest_asking_price[_company_address]
    mapping(address => uint256) public lowest_bidding_price; // lowest_bidding_price[_company_address]
    mapping(address => uint256) public highest_bidding_price; // highest_bidding_price[_company_address]

    mapping(address => mapping(uint256 => uint256)) last_non_zero_len_on_bidding_price; //last_non_zero_len_on_bidding_price[_company_address][_current_price]
    mapping(address => mapping(uint256 => uint256)) last_non_zero_len_on_asking_price; //last_non_zero_len_on_bidding_price[_company_address][_current_price]

    mapping(address => mapping(uint256 => uint256)) public number_of_ask_token_on_price; // number_of_ask_token_on_price[_company_address][current_price]
    mapping(address => mapping(uint256 => uint256)) public number_of_bid_token_on_price; // number_of_bid_token_on_price[_company_address][current_price]

    mapping(address => mapping(address => uint256)) public remaining_selling_token;

    function remaining_token_for_sell( address _company_address, address _investor_address) public view returns (uint256) {
        return remaining_selling_token[_company_address][_investor_address];
    }

    mapping(address => mapping(address => uint256)) public remaining_buying_token;

    function remaining_token_for_buy(address _company_address, address _investor_address) public view returns (uint256) {
        return remaining_buying_token[_company_address][_investor_address];
    }

    struct ask_variable {
        address payable company_address;
        address payable ask_seller_address;
        uint256 number_of_token_want_to_sell;
        uint256 asking_price;
        address type_a1_contract_address;
        string company_name;
        uint256 company_id;
        string company_code;
        uint256 current_asking_price;
        uint256 get_bidding_buyer_len;
        uint256 current_buyer_len;
        address current_buyer_address;
    }

    function Ask_token(address payable _company_address, address payable _ask_seller_address, uint256 _number_of_token_want_to_sell, uint256 _asking_price, string memory _company_name, uint256 _company_id,string memory _company_code,address _type_a1_contract_address) external {
        ask_seller_info[_company_address][_asking_price][_ask_seller_address] = ask_seller_session_storage_struct(_company_address,_ask_seller_address,_number_of_token_want_to_sell,_asking_price);
        array_of_ask_seller_in_this_price_range[_company_address][_asking_price].push(_ask_seller_address);
        TokenTypeA1FixedPriceExchangeContract(_type_a1_contract_address).removeTokenFromPortfolio(_company_address,_ask_seller_address,_number_of_token_want_to_sell);

        ask_variable memory ask;
        ask.company_address = _company_address;
        ask.ask_seller_address = _ask_seller_address;
        ask.number_of_token_want_to_sell = _number_of_token_want_to_sell;
        ask.asking_price = _asking_price;
        ask.type_a1_contract_address = _type_a1_contract_address;
        ask.company_name = _company_name;
        ask.company_id = _company_id;
        ask.company_code = _company_code;

        if (_asking_price < lowest_asking_price[ask.company_address] || lowest_asking_price[ask.company_address] == 0) {
            lowest_asking_price[ask.company_address] = _asking_price;
        }
        if (_asking_price > highest_asking_price[ask.company_address]) {
            highest_asking_price[ask.company_address] = _asking_price;
        }

        remaining_selling_token[ask.company_address][ask.ask_seller_address] += ask.number_of_token_want_to_sell;
        number_of_ask_token_on_price[ask.company_address][ask.asking_price] += ask.number_of_token_want_to_sell;
        if (highest_bidding_price[ask.company_address] >= ask.asking_price && highest_bidding_price[ask.company_address] != 0) {
            uint256 price_difference_between_bidding_asking = highest_bidding_price[ask.company_address] - ask.asking_price;
            for (uint256 i = 0; i <= price_difference_between_bidding_asking; i++) {
                ask.current_asking_price = highest_bidding_price[ask.company_address];
                ask.get_bidding_buyer_len = array_of_bid_buyer_in_this_price_range[ask.company_address][ask.current_asking_price].length - last_non_zero_len_on_bidding_price[ask.company_address][ask.current_asking_price];
                ask_seller_session_storage_struct storage current_seller_info = ask_seller_info[ask.company_address][ask.asking_price][ask.ask_seller_address];

                for (uint256 x = 1; x <= ask.get_bidding_buyer_len; x++) {
                    ask.current_buyer_len = last_non_zero_len_on_bidding_price[ask.company_address][ask.current_asking_price];
                    ask.current_buyer_address = array_of_bid_buyer_in_this_price_range[ask.company_address][ask.current_asking_price][ask.current_buyer_len];
                    bid_buyer_session_storage_struct storage current_buyer_info = bid_buyer_info[ask.company_address][ask.current_asking_price][ask.current_buyer_address];

                    if (current_buyer_info.how_much_token_want_to_purchased == 0) {
                        last_non_zero_len_on_bidding_price[current_buyer_info.company_address][ask.current_asking_price] += 1;
                        continue;
                    }

                    if (current_seller_info.how_much_token_want_to_sell > current_buyer_info.how_much_token_want_to_purchased) {
                        (bool success, ) = ask.ask_seller_address.call{value: (current_buyer_info.how_much_token_want_to_purchased * ask.current_asking_price * 1000000000)}("");
                        require(success, "Transaction Failed");

                        if (TokenTypeA1FixedPriceExchangeContract(ask.type_a1_contract_address).isInvestor(ask.company_address, ask.current_buyer_address) == true) {
                            TokenTypeA1FixedPriceExchangeContract(ask.type_a1_contract_address).addTokenInPortfolio(ask.company_address, ask.current_buyer_address, current_buyer_info.how_much_token_want_to_purchased);
                        } else {
                            TokenTypeA1FixedPriceExchangeContract(ask.type_a1_contract_address).addInvestor(ask.company_address, ask.current_buyer_address, ask.company_id, current_buyer_info.how_much_token_want_to_purchased, ask.company_name,ask.company_code);
                        }

                        current_seller_info.how_much_token_want_to_sell -= current_buyer_info.how_much_token_want_to_purchased;
                        remaining_buying_token[current_buyer_info.company_address][current_buyer_info.investor_address] = 0;
                        remaining_selling_token[ask.company_address][ask.ask_seller_address] -= current_buyer_info.how_much_token_want_to_purchased;

                        last_non_zero_len_on_bidding_price[ask.company_address][ask.current_asking_price] = ask.current_buyer_len + 1;
                        number_of_ask_token_on_price[ask.company_address][ask.asking_price] -= current_buyer_info.how_much_token_want_to_purchased;
                        number_of_bid_token_on_price[ask.company_address][ask.current_asking_price] -= current_buyer_info.how_much_token_want_to_purchased;

                        current_buyer_info.how_much_token_want_to_purchased = 0;
                        last_exchange_price[ask.company_address] = ask.current_asking_price;
                        continue;
                    } else {
                        uint256 tokens = current_buyer_info.how_much_token_want_to_purchased - current_seller_info.how_much_token_want_to_sell;
                        (bool success, ) = ask.ask_seller_address.call{value: (current_seller_info.how_much_token_want_to_sell * ask.current_asking_price *1000000000)}("");
                        require(success, "Transaction Failed");

                        if (TokenTypeA1FixedPriceExchangeContract(ask.type_a1_contract_address).isInvestor(ask.company_address, ask.current_buyer_address) == true) {
                            TokenTypeA1FixedPriceExchangeContract(ask.type_a1_contract_address).addTokenInPortfolio(ask.company_address, ask.current_buyer_address, current_seller_info.how_much_token_want_to_sell);
                        } else {
                            TokenTypeA1FixedPriceExchangeContract(ask.type_a1_contract_address).addInvestor(ask.company_address,ask.current_buyer_address,ask.company_id,current_seller_info.how_much_token_want_to_sell,ask.company_name,ask.company_code);
                        }

                        current_buyer_info.how_much_token_want_to_purchased -= current_seller_info.how_much_token_want_to_sell;
                        number_of_ask_token_on_price[ask.company_address][ask.asking_price] -= current_seller_info.how_much_token_want_to_sell;
                        number_of_bid_token_on_price[ask.company_address][ask.current_asking_price] -= current_seller_info.how_much_token_want_to_sell;

                        remaining_selling_token[ask.company_address][ask.ask_seller_address] = 0;
                        remaining_buying_token[current_buyer_info.company_address][current_buyer_info.investor_address] -= current_seller_info.how_much_token_want_to_sell;

                        if (tokens == 0) {
                            last_non_zero_len_on_bidding_price[ask.company_address][ask.current_asking_price] = ask.current_buyer_len +1;
                            highest_bidding_price[ask.company_address] = ask.current_asking_price - 1;
                        }

                        highest_bidding_price[ask.company_address] = ask.current_asking_price;
                        last_exchange_price[ask.company_address] = ask.current_asking_price;
                        current_seller_info.how_much_token_want_to_sell = 0;
                        break;
                    }
                }

                if (current_seller_info.how_much_token_want_to_sell != 0) {
                    highest_bidding_price[ask.company_address] = ask.current_asking_price -1;
                    continue;
                } else {
                    break;
                }
            }
        }
    }

    function View_instantly_selling_price(address _company_address,uint256 _number_of_token_want_to_sell) public view returns (uint256, uint256) {
        uint256 bidding_price_range = highest_bidding_price[_company_address] - lowest_bidding_price[_company_address];
        uint256 selling_price;
        uint256 number_of_token_want_to_sell = _number_of_token_want_to_sell;

        for (uint256 i = 0; i <= bidding_price_range; i++) {
            uint256 current_price = highest_bidding_price[_company_address] - i;

            if (number_of_bid_token_on_price[_company_address][current_price] >= number_of_token_want_to_sell) {
                selling_price += number_of_token_want_to_sell * current_price;
                return (current_price, selling_price);
                // break;
            } else {
                selling_price += number_of_bid_token_on_price[_company_address][current_price] * current_price;
                number_of_token_want_to_sell -= number_of_bid_token_on_price[_company_address][current_price];

                if (current_price == lowest_bidding_price[_company_address]) {
                    return (0, 0);
                    // break;
                }
                continue;
            }
        }
        return (0, 0);
    }

    struct bid_variable {
        address payable company_address;
        address payable bid_buyer_address;
        uint256 how_much_token_want_to_purchased;
        uint256 bid_buying_price;
        string company_name;
        uint256 company_id;
        string company_code;
        address type_a1_contract_address;
        uint256 current_bidding_price;
        uint256 available_ask_investor_len;
        uint256 current_seller_len;
        address current_seller_address;
        uint256 total_address_len;
    }

    function Bid_token(address payable _company_address,address payable _bid_buyer_address, uint256 _how_much_token_want_to_purchased, uint256 _bid_buying_price, string memory _company_name, uint256 _company_id,string memory _company_code, address _type_a1_contract_address) external payable {
        bid_buyer_info[_company_address][_bid_buying_price][_bid_buyer_address] = bid_buyer_session_storage_struct(_company_address,_bid_buyer_address,_how_much_token_want_to_purchased,_bid_buying_price);
        array_of_bid_buyer_in_this_price_range[_company_address][_bid_buying_price].push(_bid_buyer_address);

        bid_variable memory bid;
        bid.company_address = _company_address;
        bid.bid_buyer_address = _bid_buyer_address;
        bid.how_much_token_want_to_purchased = _how_much_token_want_to_purchased;
        bid.bid_buying_price = _bid_buying_price;
        bid.company_name = _company_name;
        bid.company_id = _company_id;
        bid.company_code = _company_code;
        bid.type_a1_contract_address = _type_a1_contract_address;

        if (bid.bid_buying_price < lowest_bidding_price[bid.company_address] || lowest_bidding_price[bid.company_address] == 0) {
            lowest_bidding_price[bid.company_address] = bid.bid_buying_price;
        }
        if (bid.bid_buying_price > highest_bidding_price[bid.company_address]) {
            highest_bidding_price[bid.company_address] = bid.bid_buying_price;
        }

        remaining_buying_token[bid.company_address][bid.bid_buyer_address] += bid.how_much_token_want_to_purchased;
        number_of_bid_token_on_price[bid.company_address][bid.bid_buying_price] += bid.how_much_token_want_to_purchased;
        if (bid.bid_buying_price >= lowest_asking_price[bid.company_address] && lowest_asking_price[bid.company_address] != 0) {
            uint256 _price_difference_between_bidding_price_and_lowest_asking_price = bid.bid_buying_price - lowest_asking_price[bid.company_address];
            for (uint256 i = 0; i <=_price_difference_between_bidding_price_and_lowest_asking_price; i++) {
                bid.current_bidding_price = lowest_asking_price[bid.company_address];
                bid_buyer_session_storage_struct storage current_buyer_info = bid_buyer_info[bid.company_address][bid.bid_buying_price][bid.bid_buyer_address];

                uint256 _available_ask_investor_len = array_of_ask_seller_in_this_price_range[bid.company_address][lowest_asking_price[bid.company_address]].length -last_non_zero_len_on_asking_price[bid.company_address][bid.current_bidding_price];
                for (uint256 x = 1; x <= _available_ask_investor_len; x++) {
                    bid.current_seller_len = last_non_zero_len_on_asking_price[bid.company_address][bid.current_bidding_price];
                    bid.current_seller_address = array_of_ask_seller_in_this_price_range[bid.company_address][bid.current_bidding_price][bid.current_seller_len];

                    ask_seller_session_storage_struct storage current_seller_info = ask_seller_info[bid.company_address][bid.current_bidding_price][bid.current_seller_address];

                    if (current_seller_info.how_much_token_want_to_sell == 0) {
                        last_non_zero_len_on_asking_price[bid.company_address][bid.current_bidding_price] += 1;
                        continue;
                    }

                    if (current_buyer_info.how_much_token_want_to_purchased > current_seller_info.how_much_token_want_to_sell) {
                        uint256 amount = current_seller_info.how_much_token_want_to_sell * current_seller_info.ask_selling_price * 1000000000;
                        (bool success, ) = current_seller_info.investor_address.call{value: amount}("");
                        require(success, "Transaction Failed");

                        // uint _price_difference = current_buyer_info.bid_buying_price - current_seller_info.ask_selling_price;
                        // if(_price_difference != 0) {
                        //     uint amount2 = current_seller_info.how_much_token_want_to_sell * _price_difference * 1000000000;
                        //     (bool success, ) = bid.bid_buyer_address.call{value: amount2}("");
                        //     require(success, "Transaction Failed");
                        // }

                        if (TokenTypeA1FixedPriceExchangeContract(bid.type_a1_contract_address).isInvestor(bid.company_address, bid.bid_buyer_address) == true) {
                            TokenTypeA1FixedPriceExchangeContract(bid.type_a1_contract_address).addTokenInPortfolio(bid.company_address, bid.bid_buyer_address, current_seller_info.how_much_token_want_to_sell);
                        } else {
                            TokenTypeA1FixedPriceExchangeContract(bid.type_a1_contract_address).addInvestor(current_buyer_info.company_address, current_buyer_info.investor_address,bid.company_id, current_seller_info.how_much_token_want_to_sell,bid.company_name,bid.company_code);
                        }

                        last_non_zero_len_on_asking_price[bid.company_address][bid.current_bidding_price] = bid.current_seller_len + 1;
                        remaining_selling_token[current_seller_info.company_address][current_seller_info.investor_address] = 0;
                        remaining_buying_token[bid.company_address][bid.bid_buyer_address] -= current_seller_info.how_much_token_want_to_sell;

                        number_of_bid_token_on_price[bid.company_address][bid.bid_buying_price] -= current_seller_info.how_much_token_want_to_sell;
                        number_of_ask_token_on_price[bid.company_address][bid.current_bidding_price] -= current_seller_info.how_much_token_want_to_sell;
                        last_exchange_price[bid.company_address] = bid.current_bidding_price;

                        current_buyer_info.how_much_token_want_to_purchased -= current_seller_info.how_much_token_want_to_sell;
                        current_seller_info.how_much_token_want_to_sell = 0;
                        continue;
                    } else {
                        uint256 _available_token = current_seller_info.how_much_token_want_to_sell - current_buyer_info.how_much_token_want_to_purchased;

                        (bool success, ) = current_seller_info.investor_address.call{value: (current_buyer_info.how_much_token_want_to_purchased * current_seller_info.ask_selling_price *1000000000)}("");
                        require(success, "Transaction Failed");

                        // uint _difference_of_price =  current_buyer_info.bid_buying_price - current_seller_info.ask_selling_price;
                        // if(_difference_of_price != 0) {
                        //     (bool success, ) = bid.bid_buyer_address.call{value: (current_buyer_info.how_much_token_want_to_purchased * _difference_of_price * 1000000000)}("");
                        //     require(success, "Transaction Failed");
                        // }

                        if (TokenTypeA1FixedPriceExchangeContract(bid.type_a1_contract_address).isInvestor(bid.company_address, bid.bid_buyer_address) == true) {
                            TokenTypeA1FixedPriceExchangeContract(bid.type_a1_contract_address).addTokenInPortfolio(bid.company_address, bid.bid_buyer_address, current_buyer_info.how_much_token_want_to_purchased);
                        } else {
                            TokenTypeA1FixedPriceExchangeContract(bid.type_a1_contract_address).addInvestor(bid.company_address, bid.bid_buyer_address, bid.company_id, current_buyer_info.how_much_token_want_to_purchased, bid.company_name, bid.company_code);
                        }

                        if (_available_token == 0) {
                            last_non_zero_len_on_asking_price[bid.company_address][bid.current_bidding_price] = bid.current_seller_len + 1;
                            lowest_asking_price[bid.company_address] = bid.current_bidding_price +1;
                        }

                        remaining_selling_token[current_seller_info.company_address][current_seller_info.investor_address] -= current_buyer_info.how_much_token_want_to_purchased;
                        remaining_buying_token[bid.company_address][bid.bid_buyer_address] = 0;
                        number_of_bid_token_on_price[bid.company_address][bid.bid_buying_price] -= current_buyer_info.how_much_token_want_to_purchased;
                        number_of_ask_token_on_price[bid.company_address][bid.current_bidding_price] -= current_buyer_info.how_much_token_want_to_purchased;

                        lowest_asking_price[bid.company_address] = bid.current_bidding_price;
                        current_seller_info.how_much_token_want_to_sell -= current_buyer_info.how_much_token_want_to_purchased;
                        current_buyer_info.how_much_token_want_to_purchased = 0;
                        last_exchange_price[bid.company_address] = bid.current_bidding_price;
                        break;
                    }
                }

                if (current_buyer_info.how_much_token_want_to_purchased != 0) {
                    lowest_asking_price[bid.company_address] = bid.current_bidding_price + 1;
                    continue;
                } else {
                    break;
                }
            }
        }
    }

    function View_instantly_buying_price( address _company_address, uint256 _number_of_token_want_to_buy ) external view returns (uint256, uint256) {
        uint256 buying_price;
        uint256 number_of_token;
        uint256 _price_range = highest_asking_price[_company_address] - lowest_asking_price[_company_address];
        number_of_token += _number_of_token_want_to_buy;

        for (uint256 i = 0; i <= _price_range; i++) {
            uint256 current_price = lowest_asking_price[_company_address] + i;

            if (number_of_ask_token_on_price[_company_address][current_price] >= number_of_token) {
                buying_price += _number_of_token_want_to_buy * current_price;
                return (current_price, buying_price);
                // break;
            } else {
                buying_price += number_of_ask_token_on_price[_company_address][current_price] * current_price;
                number_of_token -= number_of_ask_token_on_price[_company_address][current_price];

                if (current_price == highest_asking_price[_company_address]) {
                    return (0, 0);
                    // break;
                }
                continue;
            }
        }
        return (0, 0);
    }
}



contract TokenTypeA1FixedPriceExchangeContract {
    uint256 companyId;
    uint256 companySecretKey;

    constructor() {
        companyId = 0;
        companySecretKey = 747;
    }

    struct companiesStruct {
        uint256 companyId;
        address payable companyAddress;
        string companyCode;
        string name;
        uint256 tokens;
        uint256 perTokenPrice;
        uint256 maximumAmountOfTokenOneCanBuy;
    }
    companiesStruct[] public companies;

    mapping(address => bool) public isCompany;
    event companiesEvent(
        uint256 companyId,
        address payable companyAddress,
        string companyCode,
        string name,
        uint256 tokens,
        uint256 perTokenPrice,
        uint256 maximumAmountOfTokenOneCanBuy
    );


    function AddCompany(address payable _companyAddress, string memory _companyCode, string memory _name, uint256 _tokens, uint256 _companySecretKey, uint256 _perTokenPrice, uint256 _maximumAmountOfTokenOneCanBuy) external {
        require(msg.sender == _companyAddress, "Authentication Failed !!");
        require(isCompany[_companyAddress] == false, "Company already exist ..");
        require(companySecretKey == _companySecretKey, "Secret Key is not matched ..");

        companies.push(companiesStruct(companyId, _companyAddress, _companyCode, _name, _tokens, _perTokenPrice, _maximumAmountOfTokenOneCanBuy));
        isCompany[_companyAddress] = true;
        companyId += 1;
        emit companiesEvent(companyId, _companyAddress, _companyCode, _name, _tokens,_perTokenPrice,_maximumAmountOfTokenOneCanBuy);
    }

    function GetAllCompany() external view returns (companiesStruct[] memory) {
        return companies;
    }

    // List of companies Investor
    mapping(address => address[]) companyAllInvestorAddress;

    function GetCompanyAllInvestorLength(address _companyAddress) external view returns (uint256) {
        require(msg.sender == _companyAddress, "Authentication Failed !!");
        require(isCompany[_companyAddress] == true, "Company is not exist ..");
        return companyAllInvestorAddress[_companyAddress].length;
    }

    function GetCompanyAllInvestor(address _companyAddress, uint256 _id) external view returns (investorTokenInfoStruct memory) {
        require(msg.sender == _companyAddress, "Authentication Failed !!");
        require(isCompany[_companyAddress] == true, "Company is not exist ..");
        return investorTokenInfo[companyAllInvestorAddress[_companyAddress][_id]][_companyAddress];
    }

    //Investor Center
    mapping(address => mapping(address => investorTokenInfoStruct)) public investorTokenInfo;
    mapping(address => address[]) investorCurrentCompaniesList;
    mapping(address => mapping(address => bool)) public isInvestorAlreadyListed; // isInvestorAlreadyListed[_investorAddress][_companyAddress];

    struct investorTokenInfoStruct {
        address investorAddress;
        address companyAddress;
        uint256 companyId;
        uint256 numberOfTokenPurchased;
        string companyName;
        string companyCode;
    }

    event investorTokenInfoEvent(
        address investorAddress,
        address companyAddress,
        uint256 companyId,
        uint256 numberOfTokenPurchased,
        string companyName,
        string companyCode
    );


    function retrieveInvestorToken(address _companyAddress, address _investorAddress ) external view returns (uint256 numberOfTokenPurchased) {
        investorTokenInfoStruct storage getInvestorData = investorTokenInfo[_investorAddress][_companyAddress];
        return (getInvestorData.numberOfTokenPurchased);
    }

    function addTokenInPortfolio(address _companyAddress, address _investorAddress,uint256 numOfTokenAdded) external {
        investorTokenInfoStruct storage getInvestorData = investorTokenInfo[_investorAddress][_companyAddress];
        getInvestorData.numberOfTokenPurchased += numOfTokenAdded;
    }

    function removeTokenFromPortfolio(address _companyAddress, address _investorAddress, uint256 numOfTokenRemove) external {
        investorTokenInfoStruct storage getInvestorData = investorTokenInfo[_investorAddress][_companyAddress];
        getInvestorData.numberOfTokenPurchased -= numOfTokenRemove;
    }

    function isInvestor(address _companyAddress, address _investorAddress) external view returns (bool) {
        return isInvestorAlreadyListed[_investorAddress][_companyAddress];
    }

    function addInvestor(address _companyAddress, address _investorAddress, uint256 _companyId, uint256 _token, string memory _companyName, string memory _companyCode) external {
        investorTokenInfo[_investorAddress][_companyAddress] = investorTokenInfoStruct(_investorAddress, _companyAddress, _companyId, _token,_companyName, _companyCode);
        investorCurrentCompaniesList[_investorAddress].push(_companyAddress);

        isInvestorAlreadyListed[_investorAddress][_companyAddress] = true;
        companyAllInvestorAddress[_companyAddress].push(_investorAddress);
        emit investorTokenInfoEvent(_investorAddress, _companyAddress, _companyId, _token, _companyName, _companyCode);
    }

    function InvestorPurchasedTokens(address payable _investorAddress, address payable _companyAddress, uint256 _companyId, uint256 _numberOfTokenPurchased, string memory _companyName,string memory _companyCode) external {
        // require(msg.sender == _investorAddress, "Authentication Failed !!");
        companiesStruct storage getCompanyData = companies[_companyId];
        require(_numberOfTokenPurchased <= getCompanyData.maximumAmountOfTokenOneCanBuy, "You can not purchased a lot of Tokens");
        require(_numberOfTokenPurchased <= getCompanyData.tokens, "Available token is not valid.");

        getCompanyData.tokens = getCompanyData.tokens - _numberOfTokenPurchased;

        if (isInvestorAlreadyListed[_investorAddress][_companyAddress] == false) {
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

    function GetInvestorCompaniesLength(address _investorAddress) external view returns (uint256){
        // require(msg.sender == _investorAddress, "Authentication Failed !!");
        return investorCurrentCompaniesList[_investorAddress].length;
    }

    function GetInvestorCompany(address _investorAddress, uint256 _id) external view returns (investorTokenInfoStruct memory){
        // require(msg.sender == _investorAddress, "Authentication Failed !!");
        address _companyAddress = investorCurrentCompaniesList[_investorAddress][_id];
        return investorTokenInfo[_investorAddress][_companyAddress];
    }


    // Exchange Token
    function ExchangeTokens(address payable _fromInvestor, address payable _toInvestor, address payable _companyAddress, uint256 _numberOfTokenExchange ) external {
        require(msg.sender == _fromInvestor, "Authentication Failed !!");

        investorTokenInfoStruct storage getSenderInvestorData = investorTokenInfo[_fromInvestor][_companyAddress];
        require(getSenderInvestorData.numberOfTokenPurchased >= _numberOfTokenExchange, "Number of Exchange token is not valid.");
        getSenderInvestorData.numberOfTokenPurchased -= _numberOfTokenExchange;

        if (isInvestorAlreadyListed[_toInvestor][_companyAddress] == false) {
            investorTokenInfo[_toInvestor][_companyAddress] = investorTokenInfoStruct(_toInvestor, _companyAddress, getSenderInvestorData.companyId, _numberOfTokenExchange,getSenderInvestorData.companyName, getSenderInvestorData.companyCode);
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
