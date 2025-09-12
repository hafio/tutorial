# Traefik Dashboard YAML Example

The below example lets users access the Traefik Dashboard @ `https://dashboard.<DOMAIN>.<TLD>`. 

> Do note that Traefik uses `/dashboard/#` and `/api/#` paths internally for dashboard and api (necessary for dashboard to work) respectively.
> 
> The below example removes these paths and sets it at the subdomain level. Also, `/api/#` gets redirected to `api.<DOMAIN>.<TLD>`.
> 
> This complexity is not necessary if you're ok:
> - to use a single domain name for Traefik dashboards
> - show the `/dashboard/#` and `/api/#` paths

```yml
http:
  routers:
    traefik-api:
      rule: Host(`api.<DOMAIN>.<TLD>`)
      entryPoints:
        - websecure
      middlewares:
        - allow-dashboard-cors
        - strip-api
        - add-api
      service: api@internal
    traefik-dashboard-redirect-api:
      rule: Host(`dashboard.<DOMAIN>.<TLD>`) && PathPrefix(`/api/`)
      entryPoints:
        - websecure
      middlewares:
        - redirect-dashboard-to-api
      service: noop@internal
    traefik-dashboard:
      rule: Host(`dashboard.<DOMAIN>.<TLD>`)
      entryPoints:
        - websecure
      middlewares:
        - auth
        - strip-dashboard
        - add-dashboard
      service: api@internal
      
  middlewares:
    auth:
      basicAuth:
        users:
          - "<USE `htpasswd -nbB USER PASS` to generate this string - available from `apache2-utils` linux package>"
    allow-dashboard-cors:
      headers:
        accessControlAllowOriginList:
        - https://dashboard.<DOMAIN>.<TLD>
    redirect-dashboard-to-api:
      redirectRegex:
        regex: "^https://dashboard\\.<DOMAIN>\\.<TLD>/api/(.*)"
        replacement: "https://api.<DOMAIN>.<TLD>/$1"
        permanent: true
    add-api:
      addPrefix:
        prefix: "/api"
    add-dashboard:
      addPrefix:
        prefix: "/dashboard"
    strip-api:
      stripPrefix:
        prefixes: "/api"
    strip-dashboard:
      stripPrefix:
        prefixes: "/dashboard"
```