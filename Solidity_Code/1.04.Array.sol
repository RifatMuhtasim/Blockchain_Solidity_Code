// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.0;


contract Array{
    uint[] public user_id = [1, 5, 9];
    string[] public name_list = ["Rakib", "Nakib", "Muhtasim"];
    string[] public values;
    uint[][] public array2d = [ [1,7,3], [9,3,5] ];

    function addValues(string memory _value) public {
        values.push(_value);
    }
    function numberOfValues() public view returns(uint){
        return values.length;
    }

    struct User_Information {
        uint userId;
        address userAddress;
        string name;
        string email;
    }
    User_Information[] user_information;

    function addUser(uint _id, address _userAddress, string memory _name, string memory _email) public {
        user_information.push(User_Information(_id, _userAddress, _name, _email ));
    }
    function countUserLength() public view returns(uint){
        return user_information.length;
    }
}