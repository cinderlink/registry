# PermissionRegistry

## State Variables
### owner

```solidity
address owner;
```


### usersAddr

```solidity
address usersAddr;
```


### users

```solidity
UserRegistry public users;
```


### counter

```solidity
uint256 public counter = 0;
```


### permissions

```solidity
mapping(uint256 => Permission) public permissions;
```


### userPermissions

```solidity
mapping(uint256 => UserPermissions) public userPermissions;
```


### permissionIds

```solidity
mapping(string => uint256) public permissionIds;
```


## Functions
### constructor


```solidity
constructor(address _usersAddr);
```

### registerPermission


```solidity
function registerPermission(string memory _name, string memory _cid, uint256 _parent, address _owner)
    public
    returns (uint256);
```

### registerPermission


```solidity
function registerPermission(string memory _name, string memory _cid) public returns (uint256);
```

### registerPermission


```solidity
function registerPermission(string memory _name, string memory _cid, uint256 _parent) public returns (uint256);
```

### exists


```solidity
function exists(string memory _name) public view returns (bool);
```

### getPermissionId


```solidity
function getPermissionId(string memory _name) public view returns (uint256);
```

### getPermission


```solidity
function getPermission(uint256 _id) public view returns (Permission memory);
```

### getPermission


```solidity
function getPermission(string memory _name) public view returns (Permission memory);
```

### getPermissionCid


```solidity
function getPermissionCid(uint256 _id) public view returns (string memory);
```

### getPermissionCid


```solidity
function getPermissionCid(string memory _name) public view returns (string memory);
```

### getPermissionName


```solidity
function getPermissionName(uint256 _id) public view returns (string memory);
```

### getPermissionParent


```solidity
function getPermissionParent(uint256 _id) public view returns (uint256);
```

### getPermissionOwner


```solidity
function getPermissionOwner(uint256 _id) public view returns (address);
```

### updatePermissionName


```solidity
function updatePermissionName(uint256 _id, string memory _name) public;
```

### updatePermissionCid


```solidity
function updatePermissionCid(uint256 _id, string memory _cid) public;
```

### updatePermissionParent


```solidity
function updatePermissionParent(uint256 _id, uint256 _parent) public;
```

### updatePermissionOwner


```solidity
function updatePermissionOwner(uint256 _id, address _owner) public;
```

### updatePermission


```solidity
function updatePermission(uint256 _id, string memory _name, string memory _cid, uint256 _parent, address _owner)
    public;
```

### updatePermission


```solidity
function updatePermission(uint256 _id, string memory _name, string memory _cid, uint256 _parent) public;
```

### updatePermission


```solidity
function updatePermission(uint256 _id, string memory _name, string memory _cid) public;
```

### userHasPermission


```solidity
function userHasPermission(uint256 _userId, uint256 _permissionId) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(address _address, uint256 _permissionId) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(address _address, string memory _name) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(uint256 _permissionId) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(string memory _name) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(uint256 _userId, string memory _name) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(string memory _username, uint256 _permissionId) public view returns (bool);
```

### userHasPermission


```solidity
function userHasPermission(string memory _username, string memory _name) public view returns (bool);
```

### grantPermission


```solidity
function grantPermission(uint256 _userId, uint256 _permissionId) public;
```

### grantPermission


```solidity
function grantPermission(uint256 _userId, string memory _name) public;
```

### grantPermission


```solidity
function grantPermission(string memory _username, uint256 _permissionId) public;
```

### grantPermission


```solidity
function grantPermission(address _addr, uint256 _permissionId) public;
```

### grantPermission


```solidity
function grantPermission(address _addr, string memory _name) public;
```

### revokePermission


```solidity
function revokePermission(uint256 _userId, uint256 _permissionId) public;
```

### revokePermission


```solidity
function revokePermission(uint256 _userId, string memory _name) public;
```

### revokeAllPermissions


```solidity
function revokeAllPermissions(uint256 _userId) public;
```

### getUserPermissions


```solidity
function getUserPermissions(uint256 _userId, uint256 _offset, uint256 _limit) public view returns (uint256[] memory);
```

### getUserPermissions


```solidity
function getUserPermissions(uint256 _userId) public view returns (uint256[] memory);
```

### getUserPermissionsCount


```solidity
function getUserPermissionsCount(uint256 _userId) public view returns (uint256);
```

## Structs
### Permission

```solidity
struct Permission {
    uint256 id;
    uint256 parent;
    string cid;
    string name;
    address owner;
}
```

### UserPermissions

```solidity
struct UserPermissions {
    uint256 userId;
    uint256[] permissions;
    uint256 counter;
}
```

