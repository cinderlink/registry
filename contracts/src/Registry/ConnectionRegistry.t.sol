// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "./ConnectionRegistry.sol";
import "./EntityTypeRegistry.sol";
import "./SchemaRegistry.sol";
import "./EntityRegistry.sol";
import "./EntityDefinitionRegistry.sol";
import "./UserRegistry.sol";
import "./PermissionRegistry.sol";

contract ConnectionRegistryTest is Test {
    UserRegistry public users;
    PermissionRegistry public permissions;
    EntityTypeRegistry public types;
    SchemaRegistry public schemas;
    EntityRegistry public entities;
    EntityDefinitionRegistry public definitions;
    ConnectionRegistry public connections;
    address public deployer;
    uint256 userId;
    uint256 typeId;
    uint256 schemaId;
    uint256 fooId;
    uint256 fooDefinitionId;
    uint256 barId;
    uint256 barDefinitionId;

    function setUp() public {
        deployer = vm.addr(1);
        vm.startPrank(deployer);
        users = new UserRegistry();
        permissions = new PermissionRegistry(address(users));
        types = new EntityTypeRegistry("test.types", address(permissions));
        entities = new EntityRegistry("test.entities", address(permissions), address(types));
        definitions = new EntityDefinitionRegistry("test.definitions", address(permissions), address(entities), address(schemas));
        connections = new ConnectionRegistry("test.connections", address(permissions), address(definitions), address(entities));
        userId = users.register("test", "test");
        typeId = types.register("test");
        schemaId = schemas.register("test", "test");
        fooId = entities.register("foo", typeId);
        fooDefinitionId = definitions.register(fooId, schemaId, "fooCid");
        barId = entities.register("bar", typeId);
        barDefinitionId = definitions.register(barId, schemaId, "barCid");
    }

    function testLinkConnection() public {
        uint256 id = connections.connect(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_LINK());
        require(id > 0, "ConnectionRegistry: failed to create connection");

        ConnectionRegistry.Connection[] memory _connections = connections.getEntityConnections(fooDefinitionId);
        require(_connections[0].fromId == fooDefinitionId, "fromId != fooDefinitionId");
        require(_connections[0].toId == barDefinitionId, "toId != barDefinitionId");

        uint256[] memory _mutualConnectionIds = connections.getConnectionIds(fooDefinitionId, barDefinitionId);
        require(_mutualConnectionIds[0] == id, "mutualConnections[0] != id");

        ConnectionRegistry.Connection[] memory _mutualConnections = connections.getConnections(fooDefinitionId, barDefinitionId);
        require(_mutualConnections[0].fromId == fooDefinitionId, "mutualConnections[0].fromId != fooDefinitionId");
        require(_mutualConnections[0].toId == barDefinitionId, "mutualConnections[0].toId != barDefinitionId");
        require(
            _mutualConnections[0].connectionType == connections.CONNECTION_TYPE_LINK(),
            "mutualConnections[0].connectionType != CONNECTION_TYPE_LINK"
        );

        require(
            connections.exists(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_LINK()),
            "exists(fooDefinitionId, barDefinitionId, CONNECTION_TYPE_LINK) failed"
        );
    }

    function testParentChildConnection() public {
        uint256 id = connections.connect(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_PARENT());
        require(id > 0, "ConnectionRegistry: failed to create connection");

        ConnectionRegistry.Connection[] memory _connections = connections.getEntityConnections(fooDefinitionId);
        require(_connections[0].fromId == fooDefinitionId, "fromId != fooDefinitionId");
        require(_connections[0].toId == barDefinitionId, "toId != barDefinitionId");

        uint256[] memory _mutualConnectionIds = connections.getConnectionIds(fooDefinitionId, barDefinitionId);
        require(_mutualConnectionIds[0] == id, "mutualConnections[0] != id");

        ConnectionRegistry.Connection[] memory _mutualConnections = connections.getConnections(fooDefinitionId, barDefinitionId);
        require(_mutualConnections[0].fromId == fooDefinitionId, "mutualConnections[0].fromId != fooDefinitionId");
        require(_mutualConnections[0].toId == barDefinitionId, "mutualConnections[0].toId != barDefinitionId");
        require(
            _mutualConnections[0].connectionType == connections.CONNECTION_TYPE_PARENT(),
            "mutualConnections[0].connectionType != CONNECTION_TYPE_PARENT_CHILD"
        );

        require(
            connections.exists(barDefinitionId, fooDefinitionId, connections.CONNECTION_TYPE_CHILD()),
            "exists(barDefinitionId, fooDefinitionId, CONNECTION_TYPE_CHILD) failed"
        );
    }

    function testAliasConnection() public {
        uint256 id = connections.connect(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_ALIAS());
        require(id > 0, "ConnectionRegistry: failed to create connection");

        ConnectionRegistry.Connection[] memory _connections = connections.getEntityConnections(fooDefinitionId);
        require(_connections[0].fromId == fooDefinitionId, "fromId != fooDefinitionId");
        require(_connections[0].toId == barDefinitionId, "toId != barDefinitionId");

        uint256[] memory _mutualConnectionIds = connections.getConnectionIds(fooDefinitionId, barDefinitionId);
        require(_mutualConnectionIds[0] == id, "mutualConnections[0] != id");

        ConnectionRegistry.Connection[] memory _mutualConnections = connections.getConnections(fooDefinitionId, barDefinitionId);
        require(_mutualConnections[0].fromId == fooDefinitionId, "mutualConnections[0].fromId != fooDefinitionId");
        require(_mutualConnections[0].toId == barDefinitionId, "mutualConnections[0].toId != barDefinitionId");
        require(
            _mutualConnections[0].connectionType == connections.CONNECTION_TYPE_ALIAS(),
            "mutualConnections[0].connectionType != CONNECTION_TYPE_ALIAS"
        );

        require(
            connections.exists(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_ALIAS()),
            "exists(fooDefinitionId, barDefinitionId, CONNECTION_TYPE_ALIAS) failed"
        );
    }

    function testDisconnect() public {
        uint256 id = connections.connect(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_LINK());
        require(id > 0, "ConnectionRegistry: failed to create connection");

        connections.disconnect(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_LINK());
        require(
            !connections.exists(fooDefinitionId, barDefinitionId, connections.CONNECTION_TYPE_LINK()),
            "exists(fooDefinitionId, barDefinitionId, CONNECTION_TYPE_LINK) failed"
        );
        require(
            !connections.exists(barDefinitionId, fooDefinitionId, connections.CONNECTION_TYPE_LINK()),
            "exists(barDefinitionId, fooDefinitionId, CONNECTION_TYPE_LINK) failed"
        );
        require(connections.getEntityConnections(fooDefinitionId).length == 0, "getEntityConnections(fooDefinitionId).length != 0");
        require(connections.getEntityConnections(barDefinitionId).length == 0, "getEntityConnections(barDefinitionId).length != 0");
    }
}
