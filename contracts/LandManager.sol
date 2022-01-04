// SPDX-License-Identifier: MIT

// solution list of granted lands
pragma solidity 0.8.11;

import "./Ballot.sol";

contract LandManager {
    address[] private _owners;
    mapping(address => Ballot) private _ballots;

    uint256 private _currentMapHigh;
    uint256 private _currentMapWidth;

    struct Dimension {
        uint256 width;
        uint256 high;
    }

    struct Land {
        uint256 x1;
        uint256 y1;
        uint256 x2;
        uint256 y2;
        address owner;
    }

    // map to store the initial location with the respective granted land
    // mapping(uint256 => mapping(uint256 => Land)) grantedLands;

    Land[] private _grantedLands;

    constructor(uint256 hight_, uint256 width_) {
        _currentMapWidth = width_;
        _currentMapHigh = hight_;

        // set the msg.sender as initials owners
        _owners.push(msg.sender);
    }

    function askForLands(
        uint256 x1_,
        uint256 x2_,
        uint256 y1_,
        uint256 y2_
    ) public {
        address to = msg.sender;

        //check if it's get or extend land
        bool isGet = isGetLands(x2_, y2_);

        // check can reserve land
        if (isGet) {
            require(
                checkIsEmptyLand(x1_, x2_, y1_, y2_),
                "The Land has already an owner"
            );
        } else {
            require(checkCanExtedLand(x1_, y1_), "The Land can't be extended");
        }

        Ballot ballot = new Ballot(_owners, x1_, x2_, y1_, y2_, isGet, to);
        _ballots[to] = ballot;
    }

    function checkBallot(address asker_) public {
        Ballot ballotToCheck = _ballots[asker_];

        uint256 winner = ballotToCheck.winningProposal();

        Ballot.Coordinates memory coords = ballotToCheck.winnerCoords();
        bool isGet = ballotToCheck.winnerIsGetLands();
        address winnerAddr = ballotToCheck.winnerTo();
        if (winner == 0) {
            if (isGet) {
                asingLands(coords.x1, coords.x2, coords.y1, coords.y2, winnerAddr, false);
            } else {
                asingLands(coords.x1, coords.x2, coords.y1, coords.y2, winnerAddr, true);
            }
        }
    }

    function asingLands(
        uint256 x1_,
        uint256 x2_,
        uint256 y1_,
        uint256 y2_,
        address to_,
        bool isExtend_
    ) internal {
        if (isExtend_) {
            _currentMapWidth = _currentMapWidth > x2_ ? _currentMapWidth : x2_;
            _currentMapHigh = _currentMapHigh > y2_ ? _currentMapHigh : y2_;
        }
        Land memory newLand;
        newLand.x1 = x1_;
        newLand.y1 = y1_;
        newLand.x2 = x2_;
        newLand.y2 = y2_;
        newLand.owner = to_;
        _grantedLands.push(newLand);
    }

    function checkIsEmptyLand(
        uint256 x1_,
        uint256 x2_,
        uint256 y1_,
        uint256 y2_
    ) internal view returns (bool) {
        // check if the desire land don't colide with granted ones
        for (uint16 i = 0; i < _grantedLands.length; i++) {
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

    function checkCanExtedLand(uint256 x1_, uint256 y1_) internal view returns (bool) {
        return x1_ > _currentMapWidth || y1_ > _currentMapHigh;
    }

    // define if the required land dimenssions are out of the current map bounds
    function isGetLands(uint256 x2_, uint256 y2_) private view returns (bool) {
        return x2_ <= _currentMapWidth || y2_ <= _currentMapHigh;
    }

    function getBallot(address addr) public view returns (Ballot) {
        return _ballots[addr];
    }

    function getGrantedLands() public view returns (Land[] memory) {
        return _grantedLands;
    }

    function getHight() public view returns (uint256) {
        return _currentMapHigh;
    }

    function getWidth() public view returns (uint256) {
        return _currentMapWidth;
    }

    function theyColide(
        uint256 x1,
        uint256 x2,
        uint256 y1,
        uint256 y2,
        uint256 xp1,
        uint256 xp2,
        uint256 yp1,
        uint256 yp2
    ) internal pure returns (bool) {
        return x1 < xp2 && x2 > xp1 && y1 < yp2 && y2 > yp1;
    }
}
