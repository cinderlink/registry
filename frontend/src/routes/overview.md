# What is the Candor Registry?

The candor registry is a global schema-based database that describes any thing and the relationships that one thing has to other things.

Anyone can contribute to the registry and add scoped definitions to existing entities.

## Why is this important?

When you have a global registry of things, you can build applications that can interact with any thing in the registry.

For example, you can aggregate public or private information about brands or products, people, or places.

## How does it work?

The registry is based on JSON schemas that define the structure of each piece of data associated with an entity.

Each entity has a unique identifier that is created when the entity is added to the registry.

This identifier is used to create definitions about that entity. Definitions are documents that fulfill a schema and apply to a specific entity.

## For example

Let's assume we have an entity in the registry called *Never Gonna Give You Up*, which is a song that we want to be able to support within multiple streaming services and audio players.

To accomplish this, we create a JSON schema that can be used to provide the necessary information about this song, where to find the file to stream, and who created it:

```json
{
    "title": "Song",
    "type": "object",
    "properties": {
        "file": {
            "type": "string",
            "format": "uri"
        },
        "artist": {
            "type": "string"
        },
        "album": {
            "type": "string"
        }
    },
    "required": ["file", "artist"]
}
```

We register this schema using the **SchemaRegistry.register** method, i.e.:

```ts
const songSchemaId = SchemaRegistry.register('song', songCid)
```

where **CID** is the unique content identifier returned from storing the file in IPFS. For the sake of this example, we'll say this call returned a schemaId of **420**.

Now anyone can look up the CID for this schema using the schemaId in the **SchemaRegistry.getCid()**
method, i.e.:

```ts
const songCid = SchemaRegistry.getCid(songSchemaId);
```

With the CID in hand, we can now retrieve the JSON file it represents from IPFS.

Next, we will register **"Never Gonna Give You Up"** as an entity. The second
parameter we provide to this method is the *EntityTypeId*.

This is either:

- "*1*" for an object or thing
- or "*2*" for a category or type of thing

So, to register *Never Gonna Give You Up* as an object entity, we call:

```ts
const songEntityId = EntityRegistry.register("Never Gonna Give You Up", 1)
```

And for the sake of the example we'll say that we get back an entityId of **69**. This entityId can now be used by anyone to talk specifically about **"Never Gonna Give You Up"** -- not *just* the song, but the idea, the music video, etc...

Next, we want to define the *song* **"Never Gonna Give You Up"**, so we need to add a definition to the DefinitionRegistry. We do that by calling
**DefinitionRegistry.register()**:

```ts
const songDefinitionId = DefinitionRegistry.register(songEntityId, songSchemaId, songCid);
```

where CID is the content identifier of the song data stored in IPFS.

Now our song data is in the registry and can be found by referencing the entity "Never Gonna Give You Up". Our streaming providers and audio players are able to know what to expect of the data, and everything is working as expected.

Next, we might want to register an "Artist" schema, and register "Rick Astley" as an artist. We'll start with the schema:

```json
{
    "title": "Artists",
    "type": "object",
    "properties": {
        "name": {
            "type": "string"
        },
        "genre": {
            "type": "string"
        },
        "albums": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string"
                    },
                    "year": {
                        "type": "integer"
                    }
                },
                "required": ["name", "year"]
            }
        }
    },
    "required": ["name", "genre", "albums"]
}
```

We register this schema using the **SchemaRegistry.register** method again:

```ts
const artistSchemaId = SchemaRegistry.register('artist', artistCid)
```

For the sake of this example, we'll say this call returned a schemaId of **421**.

Again, anyone can now look up the CID for this schema using the schemaId in the **SchemaRegistry.getCid()** method:

```ts
const artistCid = SchemaRegistry.getCid(artistSChemaId);
```

Next, we'll add a JSON document that fulfills this schema for Rick Astley to IPFS:

```json
{
    "name": "Rick Astley",
    "genre": "Rick n' Roll",
    "albums": [
        ...
    ]
}
```

And we'll add Rick Astley as an entity:

```ts
const artistEntityId = EntityRegistry.register("Rick Astley", 1)
```

For the example, we'll assume the entityId returned was *70*.
And we'll add an Artist definition for Rick:

```ts
const artistDefinitionId = DefinitionRegistry.register(
    artistEntityId,
    artistSchemaId,
    artistCid
);
```

Now we probably want to create a connection between the song *"Never Gonna Give You Up"* and the artist *"Rick Astley"*. We can accomplish this using the `ConnectionRegistry`.
The `ConnectionRegistry` allows us to create a connection between two **EntityDefinitions**. We can also check what connections exist belonging to or between **EntityDefinitions**, or between belonging to or between **Entities**.

We can call the `ConnectionRegistry.register` method to create the connection.
The first two parameters to the `ConnectionRegistry.register` method are the definition Ids we want to connect, and the third parameter is a uint8 between 1-4 describing the type of connection. The following constants are provided by the `ConnectionRegistry` contract:

```ts
uint8 public constant CONNECTION_TYPE_LINK = 1;
uint8 public constant CONNECTION_TYPE_PARENT = 2;
uint8 public constant CONNECTION_TYPE_CHILD = 3;
uint8 public constant CONNECTION_TYPE_ALIAS = 4;
```

In our example, the "Rick Astley" Artist definition is the "parent" of the "Never Gonna Give You Up" Song definition, so we will pass the artist definitionId as the first parameter, the song definitionId as the second parameter, and a connection type of `2`:

```ts
const connectionId = ConnectionRegistry.register(artistDefinitionId, songDefinitionId, 2);
```

Now our entity definitions are linked, and anyone can discover that the Song "Never Gonna Give You Up" was produced by the artist "Rick Astley":

```ts
const connections = ConnectionRegistry.getConnections(fromDefinitionId);
```

This will return an array of Connection objects, which looks like this:

```json
[
    {
        "fromId": 421,
        "toId": 420,
        "connectionType": 2,
        "contributorId": ...
    }
]
```

Where the `contributorId` is the `userId` of the user that contributed the definition.
You must obtain a `userId` for your address by registering with the `UserRegistry` before contributing data to the registry.

[Learn more about users and permissions](/guides/authentication).

This is just one example of what can be built and described using the registry contracts. To learn more about the contracts and the methods they offer, check out the following links:

- [Registry Contracts](/contracts)
- [SchemaRegistry](/contracts/schema-registry)
- [EntityRegistry](/contracts/entity-registry)
- [EntityDefinitionRegistry](/contracts/entity-definition-registry)
- [ConnectionsRegistry](/contracts/connections-registry)
