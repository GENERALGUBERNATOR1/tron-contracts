pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../ERC721/ERC721Token.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/ISettingsRegistry.sol";
import "./DSAuth.sol";
import "./SettingIds.sol";
import "./StringUtil.sol";

contract ObjectOwnership is ERC721Token("Evolution Land Objects","EVO"), DSAuth, SettingIds {
    using StringUtil for *;

    ISettingsRegistry public registry;

    // https://docs.opensea.io/docs/2-adding-metadata
    string public baseTokenURI;

    /**
     * @dev Byzantine's ObjectOwnership constructor 
     */
    constructor (address _registry) public {
        name_ = "Evolution Land Objects";
        symbol_ = "EVO";    // Evolution Land Objects
        registry = ISettingsRegistry(_registry);
    }

    function tokenURI(uint256 _tokenId) public view returns (string) {
        if (super.tokenURI(_tokenId).toSlice().empty()) {
            return baseTokenURI.toSlice().concat(StringUtil.uint2str(_tokenId).toSlice());
        }

        return super.tokenURI(_tokenId);
    }

    function setTokenURI(uint256 _tokenId, string _uri) public auth {
        _setTokenURI(_tokenId, _uri);
    }

    function setBaseTokenURI(string _newBaseTokenURI) public auth  {
        baseTokenURI = _newBaseTokenURI;
    }

    function mintObject(address _to, uint128 _objectId) public auth returns (uint256 _tokenId) {
        address interstellarEncoder = registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);

        _tokenId = IInterstellarEncoder(interstellarEncoder).encodeTokenIdForObjectContract(
            address(this), msg.sender, _objectId);
        super._mint(_to, _tokenId);
    }

    function burnObject(address _to, uint128 _objectId) public auth returns (uint256 _tokenId) {
        address interstellarEncoder = registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);

        _tokenId = IInterstellarEncoder(interstellarEncoder).encodeTokenIdForObjectContract(
            address(this), msg.sender, _objectId);
        super._burn(_to, _tokenId);
    }

    function mint(address _to, uint256 _tokenId) public auth {
        super._mint(_to, _tokenId);
    }

    function burn(address _to, uint256 _tokenId) public auth {
        super._burn(_to, _tokenId);
    }

    //@dev user invoke approveAndCall to create auction
    //@param _to - address of auction contractß
    function approveAndCall(
        address _to,
        uint _tokenId,
        bytes _extraData
    ) public {
        // set _to to the auction contract
        approve(_to, _tokenId);

        if(!_to.call(
                bytes4(keccak256("receiveApproval(address,uint256,bytes)")), abi.encode(msg.sender, _tokenId, _extraData)
                )) {
            revert();
        }
    }

    function setRegistry(address _registry) public onlyOwner {
        registry = ISettingsRegistry(_registry);
    }
}
