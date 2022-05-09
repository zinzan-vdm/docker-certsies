#### THIS IS OBVIOUSLY UNMAINTAINED

# docker-certsies

I wasn't quite happy with some of the options out there for refreshing certificates from a docker container, so I wrote this.

The focus of this image is to perform the bare minimum to obtain certs from an ACME server. This addresses the main reason I wasn't satisfied with the other options out there - they simply attempt to do too much. This image uses the provided configuration to boot an instance of [Dehydrated](https://github.com/dehydrated-io/dehydrated), perform the necessary setup for ACME verification, performs the validation using [Lexicon](https://github.com/AnalogJ/lexicon) via hooks, and then publishes the certs to a mounted volume (and optionally calls invokes your own hooks each step of the way).

## Other legendary projects that is used here and from which this borrows heavily

* [docker-dehydrated](https://github.com/matrix-org/docker-dehydrated) - Massive help as a reference for how things work in practice.
* [dehydrated](https://github.com/dehydrated-io/dehydrated)
* [Lexicon](https://github.com/AnalogJ/lexicon)

## Usage

The best way to get an idea of how the project is used would be to understand the code. This README serves as a high-level guide for usage instead of thoroughly documenting everything. If you're interested in understanding how to use this, see the Dockerfile.

### High-level explanation

We build the image with some default options. See the Environment variables below for more on that.

__NOTE:__ _The defaults are meant to fail. This forces the user to properly understand the configuration of what they are about to do._

1. Executes `/app/run.sh`
2. Configures Dehydrated and the volume mount directory `/certsies` if specified (using `/app/configure.sh`)
3. Uses Dehydrated to register the necessary accounts with the ACME provider.
4. Uses Dehydrated to create and refresh any certificates that are required in the `/certsies/domains.txt` file.
    1. If Dehydrated is configured to execute hooks, it will do so. The recommended way to execute the hooks is to set `DEHYDRATED_HOOK=/app/hooks/invoke.sh`. This proxy will execute the hook for all scripts found in `/app/hooks/hooks.d` and `/certsies/hooks`.
    2. The /certsies/certs directory will be populated with all created certificate files.

### domains.txt

This is a file which you will include in your `/certsies` mount as `/certsies/domains.txt`. The domain names specified in this file will be used by Dehydrated to issue your certificates.

For more information on how this file is structured, please see [this page](https://github.com/dehydrated-io/dehydrated/blob/master/docs/domains_txt.md) from the Dehydrated documentation.

### Environment variables

| Variable                  | Required       | Default                                                | Description |
| -- | -- | -- | -- |
| CONFIGURE                 |   | yes                                                    | Setting this to `yes` will force config to be regenerated for `/certsies`. |
| DOMAINS_TXT_PATH          |   |                                                        | You can provide an additional path to a `domains.txt` file which will be copied to `/certsies/domains.txt`. |
| LEXICON_YML_PATH          |   |                                                        | You can provide an additional path to a `lexicon.yml` file which will be copied to `/certsies/lexicon.yml`. |
| DEHYDRATED_CA             |   | https://acme-staging-v02.api.letsencrypt.org/directory | The CA to use. By default we use the LE Staging CA, but for production we obviously want to use the production CA. (`https://acme-v02.api.letsencrypt.org/directory`) |
| DEHYDRATED_CHALLENGE      |   | http-01                                                | The 2 challence types supported by Dehydrated are `http-01` and `dns-01`. |
| DEHYDRATED_HOOK           |   | /app/hooks/invoke.sh                                   | The Dehydrated compatible hook to execute. Executing `/app/hooks/invoke.sh` will run all hooks in `/app/hooks/hooks.d` and `/certsies/hooks`. |
| DEHYDRATED_KEYSIZE        |   | 4096                                                   | The keysize, probably not worth changing this ever as it will produce less secure certificates. |
| DEHYDRATED_KEY_ALGO       |   | rsa                                                    | Supports any of the options supported by Dehydrated. |
| DEHYDRATED_RENEW_DAYS     |   | 30                                                     | Determines when Dehydrated will refresh certificated. Setting this to 30 means Dehydrated will refresh any certificates that expire within the next 30 days. |
| DEHYDRATED_KEY_RENEW      |   | yes                                                    | If this is yes, Dehydrated will refresh certficiates that are due for refresh. |
| DEHYDRATED_ACCEPT_TERMS   | ✓ | no                                                     | This must be set to `yes` for the container to run. This creates your ACME account with the CA and accepts their terms. |
| DEHYDRATED_EMAIL          | ✓ |                                                        | This is required to create your account with the ACME CA. |
| LEXICON_PROVIDER          | ~ | cloudflare                                             | This is only required if the challenge type is `dns-01`. This tells Lexicon which DNS provider to use. |
| LEXICON_xxx...            | ~ |                                                        | If you don't want to configure Lexicon with  `/certsies/lexicon.yml` file, you can set their environment variables as per their documentation. |

### Challenges

Dehydrated supports `http-01` and `dns-01` ACME verification.

For examples of each of these, you can have a look at the `/examples` directory in this repo.

#### HTTP-01

If you want to use `http-01` verification, you need to be aware of how the `/certsies/wellknown` folder on the mount operates.

You can find more about how WELLKNOWN works from the Dehydrated page documenting it [here](https://github.com/dehydrated-io/dehydrated/blob/master/docs/wellknown.md).

A drawback of using `http-01` is that most ACME providers like LE will not issue certificates for wildcard (*) domains. This can be remedied by using `dns-01`.

#### DNS-01

These challenges are quite easy to manage and configure if your DNS service is supported by Lexicon. The Lexicon hook (`/app/hooks/hooks.d/lexicon-hook.sh`) provides functionality to completely handle the challenge on your behalf by connecting to your DNS provider's API and adding/removing the TXT records required.

For more information on the authentication required for each of the providers you should have a look at [this documentation](https://dns-lexicon.readthedocs.io/en/latest/configuration_reference.html#list-of-options) on Lexicon's provider support. __I would recommend using the `lexicon.yml` configuration file option and placing it at `/certsies/lexicon.yml`.__
