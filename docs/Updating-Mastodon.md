# Updating Mastodon

Run:

```bash
docker run -it --rm \
    -v /srv/kubes/pvc-682dfeff-5255-11e8-b43d-5a23da0b3fc9:/mastodon/public/assets \
    -v /srv/kubes/pvc-33f257b8-5258-11e8-b43d-5a23da0b3fc9/:/mastodon/public/packs \
    -v /srv/kubes/pvc-68303ec0-5255-11e8-b43d-5a23da0b3fc9/:/mastodon/public/system \
    gargron/mastodon:<version> rails db:migrate
```

```bash
docker run -it --rm \
    -v /srv/kubes/pvc-682dfeff-5255-11e8-b43d-5a23da0b3fc9:/mastodon/public/assets \
    -v /srv/kubes/pvc-33f257b8-5258-11e8-b43d-5a23da0b3fc9/:/mastodon/public/packs \
    -v /srv/kubes/pvc-68303ec0-5255-11e8-b43d-5a23da0b3fc9/:/mastodon/public/system \
    gargron/mastodon:<version> rails assets:precompile
```
