// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;


contract NFT_Domain_n_Storage{
    uint256 nft_domain_id;
    constructor() {
        nft_domain_id = 0;
    }

    mapping(bytes32 => bool) is_NFT_Domain;
    mapping(bytes32 => nft_domain_info_struct) nft_domain_info;
    struct nft_domain_info_struct {
        uint256 nft_domain_id;
        bytes32 nft_domain;
        address owner_address;
        uint256 created_time;
        uint256 last_updated_time;
        string store_type;
        string store;
    }

    event nft_domain_info_event (
        uint256 nft_domain_id,
        bytes32 nft_domain,
        address owner_address,
        uint256 created_time,
        uint256 last_updated_time,
        string store_type,
        string store
    );


    function Check_NFT_Domain(string memory _search_NFT_Domain) public view returns(bool){
        bytes32 nft_domain = keccak256(abi.encodePacked(_search_NFT_Domain));

        if( is_NFT_Domain[nft_domain] == true ){
            return false;
        } else {
            return true;
        }
    }


    function Create_NFT_Domain(string memory _search_nft_domain, address _owner_address, string memory _store_type, string memory _store) public {
        bytes32 nft_domain = keccak256(abi.encodePacked(_search_nft_domain));
        require(msg.sender == _owner_address, "Authentication Failed");
        require(is_NFT_Domain[nft_domain] == false, "Domain name is not available");

        nft_domain_info[nft_domain] = nft_domain_info_struct(nft_domain_id, nft_domain, _owner_address, block.timestamp, block.timestamp, _store_type, _store);
        nft_domain_id += 1;
        is_NFT_Domain[nft_domain] = true ;
        emit nft_domain_info_event(nft_domain_id, nft_domain, _owner_address, block.timestamp, block.timestamp, _store_type, _store);
    }


    function Read_NFT_Domain_block(string memory _search_nft_domain) public view returns(string memory, string memory){
        bytes32 nft_domain = keccak256(abi.encodePacked(_search_nft_domain));
        nft_domain_info_struct storage nft_domain_data = nft_domain_info[nft_domain];
        return(nft_domain_data.store_type, nft_domain_data.store);
    }


    function Update_NFT_Domain_block(string memory _search_nft_domain, address _owner_address, string memory _store_type, string memory _store) public {
        bytes32 nft_domain = keccak256(abi.encodePacked(_search_nft_domain));
        require(msg.sender == _owner_address, "Authentication Failed");
        nft_domain_info_struct storage nft_domain_data = nft_domain_info[nft_domain];
        nft_domain_data.store_type = _store_type;
        nft_domain_data.store = _store;
        nft_domain_info[nft_domain] = nft_domain_info_struct(nft_domain_data.nft_domain_id, nft_domain_data.nft_domain, nft_domain_data.owner_address, nft_domain_data.created_time, block.timestamp, nft_domain_data.store_type, nft_domain_data.store);
    }


    function Delete_NFT_Domain_block(string memory _search_nft_domain, address _owner_address) public {
        bytes32 nft_domain = keccak256(abi.encodePacked(_search_nft_domain));
        require(msg.sender == _owner_address, "Authentication Failed");
        nft_domain_info_struct storage nft_domain_data = nft_domain_info[nft_domain];

        nft_domain_data.nft_domain = 0;
        nft_domain_data.owner_address = address(0x0);
        nft_domain_data.created_time = 0;
        nft_domain_data.last_updated_time = 0;
        nft_domain_data.store_type = "";
        nft_domain_data.store = "";
        nft_domain_info[nft_domain] = nft_domain_info_struct(nft_domain_data.nft_domain_id, nft_domain_data.nft_domain, nft_domain_data.owner_address, nft_domain_data.created_time, block.timestamp, nft_domain_data.store_type, nft_domain_data.store);
    }


}

