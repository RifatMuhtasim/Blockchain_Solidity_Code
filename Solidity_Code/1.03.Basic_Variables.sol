// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


contract Basic {
    int public count = 0;
    string public myLocation = "Shahporan";
    bytes32 public name = "Rifat Muhtasim";
    address payable public myAddress = 0x73c71CF12B396B46cF730Aa66C0FDDaf15ba7A2B;
		
	function addCountValueOne() public {
        count += 1;
    }
	function getCountValue() public view returns(int) { 
			return count; 
	}
}