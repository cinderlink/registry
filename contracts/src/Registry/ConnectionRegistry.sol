// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "../util/CandorStrings.sol";
import "../util/CandorArrays.sol";
import "./PermissionedContract.sol";
import "./EntityRegistry.sol";
import "./EntityDefinitionRegistry.sol";

contract ConnectionRegistry is PermissionedContract {
    uint8 public constant CONNECTION_TYPE_LINK = 1;
    uint8 public constant CONNECTION_TYPE_PARENT = 2;
    uint8 public constant CONNECTION_TYPE_CHILD = 3;
    uint8 public constant CONNECTION_TYPE_ALIAS = 4;

    event ConnectionCreated(uint256 id, uint256 fromId, uint256 toId, uint8 connectionType, uint256 contributorId);
    event ConnectionDeleted(uint256 id, uint256 fromId, uint256 toId, uint8 connectionType, uint256 contributorId);

    struct Connection {
        uint256 id;
        uint256 fromId;
        uint256 toId;
        uint8 connectionType;
        uint256 contributorId;
    }

    struct DefinitionConnections {
        uint256 id;
        uint256[] connectionIds;
    }

    EntityRegistry public entities;
    EntityDefinitionRegistry public definitions;
    mapping(uint256 => DefinitionConnections) public definitionConnections;
    mapping(uint256 => Connection) public connections;

    uint256 public counter = 0;

    constructor(string memory _permissionPrefix, address _permissionAddr, address _definitionsAddr, address _entitiesAddr)
        PermissionedContract(msg.sender, _permissionPrefix, _permissionAddr)
    {
        definitions = EntityDefinitionRegistry(_definitionsAddr);
        entities = EntityRegistry(_entitiesAddr);
    }

    function exists(uint256 _id) public view returns (bool) {
        return connections[_id].id > 0;
    }

    function exists(uint256 _fromId, uint256 _toId, uint8 _type) public view returns (bool) {
        require(definitions.exists(_fromId), "From entity does not exist");
        require(definitions.exists(_toId), "To entity does not exist");
        for (uint256 i = 0; i < definitionConnections[_fromId].connectionIds.length; i++) {
            uint256 connectionId = definitionConnections[_fromId].connectionIds[i];
            Connection memory connection = connections[connectionId];
            if (connection.toId == _toId && connection.connectionType == _type) {
                return true;
            }
        }
        return false;
    }

    function exists(uint256 _fromId, uint256 _toId) public view returns (bool) {
        require(definitions.exists(_fromId), "From entity does not exist");
        require(definitions.exists(_toId), "To entity does not exist");
        for (uint256 i = 0; i < definitionConnections[_fromId].connectionIds.length; i++) {
            uint256 connectionId = definitionConnections[_fromId].connectionIds[i];
            Connection memory connection = connections[connectionId];
            if (connection.toId == _toId) {
                return true;
            }
        }
        return false;
    }

    function getConnectionCount(uint256 _fromId) public view returns (uint) {
        require(definitions.exists(_fromId), "From entity does not exist");
        return definitionConnections[_fromId].connectionIds.length;
    }

    function getConnections(uint256 _fromId) public view returns (uint256[] memory) {
        require(definitions.exists(_fromId), "From entity does not exist");
        return definitionConnections[_fromId].connectionIds;
    }

    function getConnectionIds(uint256 _fromId, uint256 _toId) public view returns (uint256[] memory) {
        require(definitions.exists(_fromId), "From entity does not exist");
        require(definitions.exists(_toId), "To entity does not exist");
        require(!exists(_fromId, _toId), "Connection does not exist");
        uint256[] memory results = new uint256[](0);
        for (uint256 i = 0; i < definitionConnections[_fromId].connectionIds.length; i++) {
            uint256 connectionId = definitionConnections[_fromId].connectionIds[i];
            Connection memory connection = connections[connectionId];
            if (connection.toId == _toId) {
                results = CandorArrays.push(results, connection.id);
            }
        }
        return results;
    }

    function getConnectionId(uint256 _fromId, uint256 _toId, uint8 _type) public view returns (uint256) {
        require(definitions.exists(_fromId), "From entity does not exist");
        require(definitions.exists(_toId), "To entity does not exist");
        require(!exists(_fromId, _toId), "Connection does not exist");
        for (uint256 i = 0; i < definitionConnections[_fromId].connectionIds.length; i++) {
            uint256 connectionId = definitionConnections[_fromId].connectionIds[i];
            Connection memory connection = connections[connectionId];
            if (connection.toId == _toId && connection.connectionType == _type) {
                return connectionId;
            }
        }
        return 0;
    }


    function getConnections(uint256 _fromId, uint256 _toId) public view returns (Connection[] memory) {
        require(definitions.exists(_fromId), "From entity does not exist");
        require(definitions.exists(_toId), "To entity does not exist");
        require(!exists(_fromId, _toId), "Connection does not exist");
        uint256[] memory connectionIds = getConnectionIds(_fromId, _toId);
        require(connectionIds.length > 0, "No connections found");
        Connection[] memory result = new Connection[](connectionIds.length);
        for (uint256 i = 0; i < connectionIds.length; i++){
            uint256 connectionId = connectionIds[i];
            result[i] = connections[connectionId];
        }
        return result;
    }

    function getConnection(uint256 _fromId, uint256 _toId, uint8 _type) public view returns (Connection memory) {
        require(definitions.exists(_fromId), "From entity does not exist");
        require(definitions.exists(_toId), "To entity does not exist");
        require(!exists(_fromId, _toId, _type), "Connection does not exist");
        uint256 connection = getConnectionId(_fromId, _toId, _type);
        require(connection > 0, "Connection does not exist");
        return connections[connection];
    }

    function connect(uint256 _fromId, uint256 _toId, uint8 _type) public returns (uint256) {
        requirePermission("connect");
        require(definitions.exists(_fromId), "From definition does not exist");
        require(definitions.exists(_toId), "To definition does not exist");
        require(!exists(_fromId, _toId, _type), "Connection already exists");
        uint256 contributorId = permissions.users().getId(msg.sender);
        uint256 connectionId = ++counter;
        Connection memory connection = Connection(connectionId, _fromId, _toId, _type, contributorId);
        connections[connectionId] = connection;
        definitionConnections[_fromId].connectionIds.push(connectionId);
        emit ConnectionCreated(connectionId, _fromId, _toId, _type, contributorId);

        // Create a corresponding connection in the other direction
        uint256 reverseConnectionId = ++counter;
        uint8 reverseConnectionType = _type == CONNECTION_TYPE_PARENT
            ? CONNECTION_TYPE_CHILD
            : _type == CONNECTION_TYPE_CHILD ? CONNECTION_TYPE_PARENT : _type;
        Connection memory reverseConnection =
            Connection(reverseConnectionId, _toId, _fromId, reverseConnectionType, contributorId);
        connections[reverseConnectionId] = reverseConnection;
        definitionConnections[_toId].connectionIds.push(reverseConnectionId);
        emit ConnectionCreated(reverseConnectionId, _toId, _fromId, reverseConnectionType, contributorId);

        return connectionId;
    }

    function disconnect(uint256 _fromId, uint256 _toId, uint8 _type) public {
        requirePermission("disconnect");
        require(definitions.exists(_fromId), "From definition does not exist");
        require(definitions.exists(_toId), "To definition does not exist");
        require(exists(_fromId, _toId, _type), "Connection does not exist");
        DefinitionConnections memory def = definitionConnections[_fromId];
        uint256[] memory matches = def.connectionIds;
        uint256 connectionId = 0;
        for (uint256 i = 0; i < matches.length; i++) {
            Connection memory connection = connections[matches[i]];
            if (connection.toId == _toId && connection.connectionType == _type) {
                connectionId = connection.id;
                break;
            }
        }
        require(connectionId > 0, "Connection does not exist");
        uint256 contributorId = permissions.users().getId(msg.sender);
        delete connections[connectionId];
        definitionConnections[_fromId].connectionIds = CandorArrays.remove(def.connectionIds, connectionId);
        emit ConnectionDeleted(connectionId, _fromId, _toId, _type, contributorId);

        uint8 reverseConnectionType = _type == CONNECTION_TYPE_PARENT
            ? CONNECTION_TYPE_CHILD
            : _type == CONNECTION_TYPE_CHILD ? CONNECTION_TYPE_PARENT : _type;
        Connection memory reverseEntity = getConnection(_toId, _fromId, reverseConnectionType);
        delete connections[reverseEntity.id];
        definitionConnections[_toId].connectionIds =
            CandorArrays.remove(definitionConnections[_toId].connectionIds, reverseEntity.id);
        emit ConnectionDeleted(reverseEntity.id, _toId, _fromId, reverseConnectionType, contributorId);
    }

    function disconnect(uint256 _fromId, uint256 _toId) public {
        requirePermission("disconnect");
        require(definitions.exists(_fromId), "From definition does not exist");
        require(definitions.exists(_toId), "To definition does not exist");
        DefinitionConnections memory def = definitionConnections[_fromId];
        uint256[] memory matches = def.connectionIds;
        for (uint256 i = 0; i < matches.length; i++) {
            Connection memory connection = connections[matches[i]];
            if (connection.toId == _toId) {
                delete connections[connection.id];
                definitionConnections[_fromId].connectionIds = CandorArrays.remove(def.connectionIds, connection.id);
            }
        }
    }

    function getEntityConnectionIds(uint256 _entityId) public view returns (uint256[] memory) {
        uint256[] memory entityDefinitionIds = definitions.getEntityDefinitionIds(_entityId);
        uint256[] memory connectionIds = new uint256[](0);
        for (uint256 i = 0; i < entityDefinitionIds.length; i++) {
            uint256 definitionId = entityDefinitionIds[i];
            DefinitionConnections memory def = definitionConnections[definitionId];
            connectionIds = CandorArrays.concat(connectionIds, def.connectionIds);
        }

        return connectionIds;
    }

    function getEntityConnections(uint256 _entityId) public view returns (Connection[] memory) {
        uint256[] memory connectionIds = getEntityConnectionIds(_entityId);
        Connection[] memory result = new Connection[](connectionIds.length);
        for (uint256 i = 0; i < connectionIds.length; i++) {
            result[i] = connections[connectionIds[i]];
        }

        return result;
    }

    function getEntityConnectionIds(uint256 _fromEntityId, uint256 _toEntityId) public view returns (uint256[] memory) {
        Connection[] memory conns = getEntityConnections(_fromEntityId);
        uint256[] memory result = new uint256[](0);
        for (uint256 i = 0; i < conns.length; i++) {
            if (conns[i].toId == _toEntityId) {
                CandorArrays.push(result, conns[i].id);
            }
        }
        return result;
    }

    function getEntityConnections(uint256 _fromEntityId, uint256 _toEntityId) public view returns (Connection[] memory) {
        uint256[] memory connectionIds = getEntityConnectionIds(_fromEntityId, _toEntityId);
        Connection[] memory result = new Connection[](connectionIds.length);
        for (uint256 i = 0; i < connectionIds.length; i++) {
            result[i] = connections[connectionIds[i]];
        }
        return result;
    }
}
