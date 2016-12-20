

### Streams

  POST    /streams      { name: 'default' }
  PUT     /streams/:id  { name: 'new-default' }
  DELETE  /streams/:id
  GET     /streams

### Feeds

POST     /streams/:id/feeds    [{ id: 1, score: 1 }, { id: 2, score: 2 }]
DELETE   /streams/:id/feeds    [{ id: 1 }, { id: 2 }]

### Follow/Unfollow

POST      /streams/:id/follow     [{ id: 'stream-1' }, { id: 'stream-2' }]
DELETE    /streams/:id/unfollow   [{ id: 'stream-1' }, { id: 'stream-2' }]

On follow we should merge streams and post it as one stream.
On unfollow we should unmerge streams and post it as one reduced stream.

Authentication could be done by adding `authentication_token`.
