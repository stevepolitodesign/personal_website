---
title: "How to Deploy a Sage Theme to WP Engine"
categories: ["WordPress"]
resources: [
    {
        title: "Sage Theme Deployment",
        url: "https://roots.io/sage/docs/theme-deployment/"
    },
    {
        title: "Sage 9 on WPEngine Discourse",
        url: "https://discourse.roots.io/t/sage-9-on-wpengine/9090/32"
    },
    {
        title: "DeployHQ Build Piplines",
        url: "https://www.deployhq.com/support/build-pipelines"
    }    
]
date: 2020-03-10
---

{% youtube "https://www.youtube.com/embed/qLydfI8ka4E" %}

[Sage](https://roots.io/sage/) is WordPress starter theme with a modern development workflow. However, deploying a Sage theme can be difficult because of its [dependencies](https://roots.io/sage/docs/theme-installation/), most notably [Composer](https://getcomposer.org/download/) and [Yarn](https://classic.yarnpkg.com/en/docs/install). In order to [deploy a Sage theme](https://roots.io/sage/docs/theme-deployment/), you need to be able to run both `Composer` and `Yarn` on your server. Furthermore, Sage doesn't [officially support hosting at WP Engine](https://roots.io/sage/docs/theme-deployment/#deploying-sage-on-wp-engine). You could [deploy Sage via FTP](https://roots.io/sage/docs/theme-deployment/#deploying-sage-via-ftp), but this approach is error prone and inefficient. Fortunately, there are services such as [DeployBot](https://deploybot.com/) and [DeployHQ](https://www.deployhq.com/) that can run these builds, and them push the distributed files to the server. For this tutorial, I am going to be using DeployHQ.

## Step 1: Update Sage Configuration

Before we can configure DeployHQ to build our Sage theme, we need to take care of a [bug](https://discourse.roots.io/t/white-screen-of-death-sage-cant-find-compiled-templates-after-wpe-deploy/15523/8) in `config/view.php` that causes a [wsod](https://en.wikipedia.org/wiki/Screen_of_death).

Update `wp-content/themes/your-theme/config/view.php` by replacing `'compiled' => wp_upload_dir()['basedir'].'/cache',` with `'compiled' => '/tmp/sage-cache',`

> The rest of the tutorial will assume you are using DeployHQ to handle building and deploying your Sage theme

## Step 2: Configure DeployHQ Servers & Groups

Next we need to configure both the deployment path and the update excluded files for future deployments.

### Step 2.1: Update Your Deployment Path

Update the deployment path to where on the server should your files be placed. In this case, we just want to upload the theme.

![deployment path](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/deployment-options-cropped.png)

`wp-content/themes/your-theme`

### Step 2.2: Update Your Excluded Files

Update your excluded files, ensuring to exclude `wp-content/themes/your-theme/node_modules/**`. I am a bit aggressive, and also exclude `node_modules/**`. This ensures that the `node_modules` folder is not uploaded to our server during deployment.

![exclude files](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/exclude-files-cropped.png)

## Step 3: Configure DeployHQ Build Pipeline

Next we need to add and configure our build pipelines, so that we can [deploy a Sage theme](https://roots.io/sage/docs/theme-deployment/) since we can't run those commands on a WP Engine server.

![build pipeline](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/build-pipeline.png)

### Step 3.1: Create a Composer Command

Assuming your repository is initialized in the root of your WordPress install, add the following build command.

```
cd wp-content/themes/your-theme
composer install --no-dev
```

![composer build pipeline](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/build-pipeline-composer.png)

However, if your repository is initialized in your theme, just add the following build command.

```
composer install --no-dev
```

### Step 3.2: Create a Yarn Command

Assuming your repository is initialized in the root of your WordPress install, add the following build command.

```
cd wp-content/themes/your-theme
yarn install && yarn run build:production
```

![composer build pipeline](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/build-pipeline-yarn.png)

However, if your repository is initialized in your theme, just add the following build command.

```
yarn install && yarn run build:production
```

### Step 3.3: Update Cached Files

Assuming your repository is initialized in the root of your WordPress install, add the following cached files.

![cached files](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/cached-files.png)

`wp-content/themes/your-theme/vendor/**` and `wp-content/themes/your-theme/node_modules/**`

However, if your repository is initialized in your theme, just add the following.

`vendor/**` and `node_modules/**`

### Step 3.4: Update Node Version

Finally, update the version of Node to whatever version you are successfully using locally. In my case, I am am running version 10.

![build pipeline node version](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/build-pipeline-node-version.png)

## Deploying

Now, when you deploy your theme you should see the build steps.

![yarn install output](/assets/images/posts/how-to-deploy-a-sage-theme-to-wp-engine/deploy-hq-build.png)
