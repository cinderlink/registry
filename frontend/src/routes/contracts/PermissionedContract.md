# PermissionedContract

## State Variables
### owner

```solidity
address owner;
```


### permissionAddr

```solidity
address permissionAddr;
```


### permissionPrefix

```solidity
string permissionPrefix;
```


### permissions

```solidity
PermissionRegistry permissions;
```


## Functions
### constructor


```solidity
constructor(address _owner, string memory _prefix, address _addr);
```

### permissionKey


```solidity
function permissionKey(string memory _permission) internal view returns (string memory);
```

### permissionKey


```solidity
function permissionKey(uint256 _entityId, string memory _permission) internal view returns (string memory);
```

### userHasPermission


```solidity
function userHasPermission(string memory _permission, address _address) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(uint256 _entityId, string memory _permission, address _address) public view returns (bool);
```

### requirePermission


```solidity
function requirePermission(string memory _permission) public view;
```

### requirePermission


```solidity
function requirePermission(uint256 _entityId, string memory _permission) public view;
```

### grantPermission


```solidity
function grantPermission(string memory _permission, address _address) public;
```

### grantPermission


```solidity
function grantPermission(uint256 _entityId, string memory _permission, address _address) public;
```

