// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LanguageGame {
    struct Translation {
        address player;
        string word;
        string translation;
        uint256 votesFor;
        uint256 votesAgainst;
        bool resolved;
    }

    Translation[] public translations;
    mapping(address => uint256) public scores;

    event NewTranslation(uint256 translationId, address player, string word);
    event Vote(uint256 translationId, address voter, bool inFavor);
    event Resolved(uint256 translationId, bool accepted);

    function submitTranslation(string memory _word, string memory _translation) public {
        translations.push(Translation(msg.sender, _word, _translation, 0, 0, false));
        emit NewTranslation(translations.length - 1, msg.sender, _word);
    }

    function vote(uint256 _translationId, bool _inFavor) public {
        require(_translationId < translations.length, "Invalid translation ID");
        require(!translations[_translationId].resolved, "Already resolved");

        if (_inFavor) {
            translations[_translationId].votesFor++;
        } else {
            translations[_translationId].votesAgainst++;
        }

        emit Vote(_translationId, msg.sender, _inFavor);

        if (translations[_translationId].votesFor + translations[_translationId].votesAgainst >= 5) {
            resolve(_translationId);
        }
    }

    function resolve(uint256 _translationId) internal {
        Translation storage t = translations[_translationId];
        t.resolved = true;

        if (t.votesFor > t.votesAgainst) {
            scores[t.player]++;
            emit Resolved(_translationId, true);
        } else {
            emit Resolved(_translationId, false);
        }
    }

    function getScore(address _player) public view returns (uint256) {
        return scores[_player];
    }
}
