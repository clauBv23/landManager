// SPDX-License-Identifier: MIT

// solution list of granted lands

/* TODO: 
        -check safe math
*/
pragma solidity 0.8.11;

import "./Ballot.sol";
import "hardhat/console.sol";

contract LandManager {
    address[] private _owners;
    mapping(address => bool) private _ownersDefined;
    mapping(address => Ballot) private _ballots;

    struct Map {
        uint32 x1;
        uint32 x2;
        uint32 y1;
        uint32 y2;
        uint32 high;
        uint32 width;
    }

    struct Land {
        uint32 x1;
        uint32 y1;
        uint32 x2;
        uint32 y2;
        address owner;
    }

    // map to store the initial location with the respective granted land
    // mapping(uint256 => mapping(uint256 => Land)) grantedLands;

    Map private map;
    Land[] private _grantedLands;

    constructor(
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_
    ) {
        map.x1 = x1_;
        map.x2 = x2_;
        map.y1 = y1_;
        map.y2 = y2_;

        //! check safe math
        map.width = x2_ - x1_;
        map.high = y2_ - y1_;

        // set the msg.sender as initials owners
        _ownersDefined[msg.sender] = true;
        _owners.push(msg.sender);
    }

    function askForLands(
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_
    ) public {
        //check if it's get or extend land
        require(
            isGetLands(x1_, x2_, y1_, y2_),
            "The requested land is out of the map sizes"
        );
        // console.log("isGet", isGet);

        // check can reserve land
        // console.log(x1_, x2_, y1_, y2_);
        require(checkIsEmptyLand(x1_, x2_, y1_, y2_), "The Land has already an owner");
        Ballot ballot = new Ballot(_owners, x1_, x2_, y1_, y2_, true, msg.sender);
        _ballots[msg.sender] = ballot;
    }

    function extendLands(
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_
    ) public {
        // check if it's out of the map
        require(!isGetLands(x1_, x2_, y1_, y2_), "The Land can't be extended");
        Ballot ballot = new Ballot(_owners, x1_, x2_, y1_, y2_, false, msg.sender);
        _ballots[msg.sender] = ballot;
    }

    function checkBallot(address asker_) public {
        Ballot ballotToCheck = _ballots[asker_];

        uint256 winner = ballotToCheck.winningProposal();

        Ballot.Coordinates memory coords = ballotToCheck.winnerCoords();

        bool isGet = ballotToCheck.winnerIsGetLands();
        address winnerAddr = ballotToCheck.winnerTo();
        // console.log(winner);
        if (winner == 1) {
            if (isGet) {
                asingLands(coords.x1, coords.x2, coords.y1, coords.y2, winnerAddr);
            } else {
                extendMap(coords.x1, coords.x2, coords.y1, coords.y2);
            }
        }
    }

    function extendMap(
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_
    ) internal {
        map.x1 = map.x1 < x1_ ? map.x1 : x1_;
        map.x2 = map.x2 > x2_ ? map.x2 : x2_;
        map.y1 = map.y1 < y1_ ? map.y1 : y1_;
        map.y2 = map.y2 > y2_ ? map.y2 : y2_;

        map.width = map.x2 - map.x1;
        map.high = map.y2 - map.y1;
    }

    function asingLands(
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_,
        address to_
    ) internal {
        Land memory newLand;
        newLand.x1 = x1_;
        newLand.y1 = y1_;
        newLand.x2 = x2_;
        newLand.y2 = y2_;
        newLand.owner = to_;
        // add land to granted lands
        _grantedLands.push(newLand);

        // add to owners list
        if (!_ownersDefined[to_]) {
            _ownersDefined[to_] = true;
            _owners.push(to_);
        }
    }

    function checkIsEmptyLand(
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_
    ) internal view returns (bool) {
        // check if the desire land don't colide with granted ones

        for (uint256 i = 0; i < _grantedLands.length; i++) {
            if (
                theyColide(
                    x1_,
                    x2_,
                    y1_,
                    y2_,
                    _grantedLands[i].x1,
                    _grantedLands[i].x2,
                    _grantedLands[i].y1,
                    _grantedLands[i].y2
                )
            ) {
                return false;
            }
        }
        return true;
    }

    // define if the required land dimenssions are out of the current map bounds
    function isGetLands(
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_
    ) private view returns (bool) {
        return x1_ >= map.x1 && x2_ <= map.x2 && y1_ >= map.y1 && y2_ <= map.y2;
    }

    function getBallot(address addr) public view returns (Ballot) {
        return _ballots[addr];
    }

    function getGrantedLands() public view returns (Land[] memory) {
        return _grantedLands;
    }

    function getHight() public view returns (uint32) {
        return map.high;
    }

    function getWidth() public view returns (uint32) {
        return map.width;
    }

    function getOwners() public view returns (address[] memory) {
        return _owners;
    }

    function theyColide(
        uint32 x1,
        uint32 x2,
        uint32 y1,
        uint32 y2,
        uint32 xp1,
        uint32 xp2,
        uint32 yp1,
        uint32 yp2
    ) internal pure returns (bool) {
        return x1 <= xp2 && x2 >= xp1 && y1 <= yp2 && y2 >= yp1;
    }
}
