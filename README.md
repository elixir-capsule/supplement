# Capsule Supplement

Starter pack for using [Capsule](github.com/elixir-capsule/capsule) with common upload sources and storage solutions.

Supplement's only *required* dependency is Capsule itself. However, some of the implementations might require further dependencies. In order to use them, consult the `dependencies` section for what to add to your project.

## Storages

The Supplement ships with the following storage implementations:

* [Disk](#Disk)
* [S3](#S3)

### Disk

This saves uploaded files to a local disk. It is useful for caching uploads while you validate other data, and/or perform some file processing.

#### configuration

* To set the root directory where files will be stored: `Application.put_env(:capsule, Capsule.Storages.Disk, root_dir: "tmp")`

#### options

* `prefix`: This should be a valid system path that will be appended to the root. If it does not exist, Disk will create it.
* `force`: If this option is set to a truthy value, Disk will overwrite any existing file at the derived path. Use with caution!

#### notes

Since it is possible for files with the same name to be uploaded multiple times, Disk needs some additional info to uniquely identify the file. Disk *does not* overwrite files with the same name by default. To ensure an upload can be stored, the combination of the `Upload.name` and `prefix` should be unique.

### S3

This storage uploads files to [AWS's S3](https://aws.amazon.com/s3/) service. It also works with [Digital Ocean Spaces](https://www.digitalocean.com/products/spaces/).

#### configuration

* To set the bucket where files will be stored: `Application.put_env(:capsule, Capsule.Storages.S3, bucket: "whatever")`

#### options

* prefix: A string to prepend to the upload's key

#### dependencies

```
{:ex_aws, "~> 2.0"}
{:ex_aws_s3, "~> 2.0"}
```

## uploads

Supplement implements the `Capsule.Upload` protocol for the following modules:

* [URI](#URI)

### URI

This is useful for transferring files already hosted elsewhere, for example in cloud storage not controlled by your application, or a [TUS server](https://tus.io/).

You can use it to allow users to post a url string in lieu of downloading and reuploading a file. A Phoenix controller action implementing this feature might look like this:

```
def attach(conn, %{"attachment" => %{"url" => url}}) when url != "" do
  URI.parse(url)
  |> Disk.put(upload)

  # ...redirect, etc
end
```

#### configuration

None

#### options

None

#### notes

This implementation imposes a hard timeout limit of 15 seconds to download the file from the remote location.
