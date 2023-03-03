# EntityDefinitionRegistry
**Inherits:**
[PermissionedContract](/contracts/PermissionedContract#41)


## State Variables
### entitiesAddr

```solidity
address public entitiesAddr;
```


### entities

```solidity
EntityRegistry public entities;
```


### schemasAddr

```solidity
address public schemasAddr;
```


### schemas

```solidity
SchemaRegistry public schemas;
```


### entityDefs

```solidity
mapping(uint256 => EntityDefinitions) public entityDefs;
```


### counter

```solidity
uint256 public counter = 0;
```


### definitions

```solidity
mapping(uint256 => Definition) public definitions;
```


### schemaDefs

```solidity
mapping(uint256 => uint256[]) public schemaDefs;
```


### userDefs

```solidity
mapping(uint256 => uint256[]) public userDefs;
```


## Functions
### constructor


```solidity
constructor(string memory _namespace, address _permissionsAddr, address _entitiesAddr, address _schemasAddr)
    PermissionedContract(msg.sender, _namespace, _permissionsAddr);
```

### register


```solidity
function register(uint256 _entityId, uint256 _schemaId, string memory _cid) public returns (uint256);
```

### exists


```solidity
function exists(uint256 _id) public view returns (bool);
```

### hasSchemaDefinition


```solidity
function hasSchemaDefinition(uint256 _entityId, uint256 _schemaId) public view returns (bool);
```

### update


```solidity
function update(uint256 _id, string memory _cid) public;
```

### remove


```solidity
function remove(uint256 _id) public;
```

### get


```solidity
function get(uint256 id) public view returns (Definition memory);
```

### getEntityId


```solidity
function getEntityId(uint256 id) public view returns (uint256);
```

### getSchemaId


```solidity
function getSchemaId(uint256 id) public view returns (uint256);
```

### getCid


```solidity
function getCid(uint256 id) public view returns (string memory);
```

### getVersion


```solidity
function getVersion(uint256 id) public view returns (uint256);
```

### getContributor


```solidity
function getContributor(uint256 id) public view returns (uint256);
```

### getEntityDefinitionIds


```solidity
function getEntityDefinitionIds(uint256 _entityId) public view returns (uint256[] memory);
```

### getEntityDefinitions


```solidity
function getEntityDefinitions(uint256 _entityId) public view returns (Definition[] memory);
```

### getEntitySchemaIds


```solidity
function getEntitySchemaIds(uint256 _entityId) public view returns (uint256[] memory);
```

### getEntitySchemaDefinitionIds


```solidity
function getEntitySchemaDefinitionIds(uint256 _entityId, uint256 _schemaId) public view returns (uint256[] memory);
```

### getEntitySchemaDefinitions


```solidity
function getEntitySchemaDefinitions(uint256 _entityId, uint256 _schemaId) public view returns (Definition[] memory);
```

### getSchemaDefinitionIds


```solidity
function getSchemaDefinitionIds(uint256 _schemaId) public view returns (uint256[] memory);
```

### getSchemaDefinitions


```solidity
function getSchemaDefinitions(uint256 _schemaId) public view returns (Definition[] memory);
```

### getSchemaEntityIds


```solidity
function getSchemaEntityIds(uint256 _schemaId) public view returns (uint256[] memory);
```

### getContributorDefinitionIds


```solidity
function getContributorDefinitionIds(uint256 _contributorId) public view returns (uint256[] memory);
```

### getContributorDefinitions


```solidity
function getContributorDefinitions(uint256 _contributorId) public view returns (Definition[] memory);
```

## Structs
### EntityDefinitions

```solidity
struct EntityDefinitions {
    uint256 id;
    uint256[] definitionIds;
    uint256[] schemaIds;
}
```

### Definition

```solidity
struct Definition {
    uint256 id;
    uint256 entityId;
    uint256 schemaId;
    uint256 version;
    uint256 contributorId;
    string cid;
}
```

