# Configuring Authentication Providers

OpenChoreo comes with a built-in Identity Provider called **Asgardeo Thunder**. However, you can configure it to use external providers like Azure AD or LDAP.

## 1. Microsoft Entra ID (Azure AD)

The easiest way to use Azure AD is to configure Backstage to use it directly as its OIDC (OpenID Connect) provider, effectively replacing Thunder for user login.

### Prerequisites
1.  Create an **App Registration** in Azure Portal.
2.  **Redirect URI**: Set to `http://localhost:7007/api/auth/default-idp/handler/frame` (Web).
3.  **Client Secret**: Generate a new client secret.
4.  **API Permissions**: Grant `email`, `openid`, and `profile`.

### Configuration
Update your `openchoreo-control-plane/values.yaml` to point to Azure AD instead of the local Thunder service.

```yaml
backstage:
  auth:
    # Replace {TENANT_ID} with your Azure Tenant ID
    authorizationUrl: "https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/authorize"
    tokenUrl: "https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/token"
  
  env:
    # Update the Client ID
    - name: OPENCHOREO_AUTH_CLIENT_ID
      value: "{YOUR_AZURE_CLIENT_ID}"
    # Update the Client Secret (Use a k8s secret in production!)
    - name: OPENCHOREO_AUTH_CLIENT_SECRET
      value: "{YOUR_AZURE_CLIENT_SECRET}"
    # Optional: Update the scope if needed
    - name: OPENCHOREO_AUTH_SCOPE
      value: "openid profile email offline_access"
```

After applying these changes (`helm upgrade ...`), clicking "Log In" will redirect users to Microsoft for authentication.

## 2. LDAP / Active Directory

Integrating LDAP is more complex because it is not an OIDC provider. You have two main options:

### Option A: Bridge via Asgardeo Thunder (Recommended for Platform)
Configure the built-in Asgardeo Thunder to use your LDAP as its "User Store". This allows Thunder to handle the LDAP connection while still providing a modern OIDC interface to Backstage.

*Note: This requires advanced configuration of the Thunder component, typically by mounting a custom `deployment.toml` or `user-mgt.xml` file into the container.*

### Option B: Direct Backstage Integration
You can configure the `ldap` provider directly in Backstage. However, since the OpenChoreo UI is pre-compiled with a specific login page, this might require:
1.  **Rebuilding the UI**: You would need to modify the source code to add a specific "Log in with LDAP" button.
2.  **Configuration**: Adding `auth.providers.ldap` configuration to `values.yaml`.

For most users, **Option A** is preferred as it keeps the UI standard, but it requires knowledge of WSO2/Asgardeo configuration files.
