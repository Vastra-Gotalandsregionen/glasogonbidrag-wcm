<#setting locale = locale>

<#-- Define services -->
<#assign expandoValueLocalService = serviceLocator.findService("com.liferay.portlet.expando.service.ExpandoValueLocalService") />
<#assign groupLocalService = serviceLocator.findService("com.liferay.portal.service.GroupLocalService") />
<#assign layoutLocalService = serviceLocator.findService("com.liferay.portal.service.LayoutLocalService") />
<#assign layoutSetLocalService = serviceLocator.findService("com.liferay.portal.service.LayoutSetLocalService") />

<#-- Define some variables -->
<#assign urlPrefix =  getUrlPrefix(request) />

<#if navigationItems.siblings?size gt 0>
	<nav class="block-navigation">
    <ul>
  		<#list navigationItems.siblings as navigationItem>

        <#assign linkUrl = navigationItem.externalLink.data />
        <#assign linkText = navigationItem.externalLink.linkText.data />
        <#assign iconClass = "" />
        <#if navigationItem.externalLink.iconClass.data?has_content>
          <#assign iconClass = navigationItem.externalLink.iconClass.data />
        </#if>

        <#if linkUrl == "">
          <#assign linkInfo = getLayoutFriendlyUrl(navigationItem) />
          <#if linkInfo?has_content>
            <#assign linkUrl = urlPrefix + linkInfo[0] />
            <#assign linkText = linkInfo[1] />
            <#assign iconClass = linkInfo[2] />
          </#if>
        </#if>

        <#assign linkTarget = "" />
        <#if navigationItem.linkTarget.data == "_BLANK">
          <#assign linkTarget = "_BLANK" />
        </#if>

        <li class="${iconClass}">
          <a href="${linkUrl}" target="${linkTarget}">
            <div>${linkText}</div>
          </a>
        </li>

      </#list>
    </ul>
	</nav>
</#if>

<#--
	Macro getUrlPrefix
	Parameter request = the request object for the freemarker context.
	Returns urlPrefix for links.
	If no virtual host exists then the urlPrefix will be for example on the form "/web/guest". Else urlPrefix will be blank
-->
<#function getUrlPrefix request>
	<#local urlPrefix = "" />

	<#local scopePlid =  getterUtil.getLong(request["theme-display"]["plid"]) />
	<#local scopeLayout =  layoutLocalService.getLayout(scopePlid) />
	<#local groupIdLong =  getterUtil.getLong(groupId) />
	<#local scopeGroup =  groupLocalService.getGroup(groupIdLong) />

	<#local scopeLayoutSet =  layoutSetLocalService.getLayoutSet(groupIdLong, scopeLayout.isPrivateLayout()) />
	<#local scopeLayoutSetVirtualHost = scopeLayoutSet.getVirtualHostname() />
	<#local hasVirtualHost =  false />

	<#if scopeLayoutSetVirtualHost != "">
		<#local hasVirtualHost =  true />
	</#if>

	<#if !hasVirtualHost>
		<#if scopeLayout.isPrivateLayout()>
			<#local urlPrefix =  "/group" />
		<#else>
			<#local urlPrefix =  "/web" />
		</#if>

		<#local urlPrefix =  urlPrefix + scopeGroup.getFriendlyURL() />
	</#if>

	<#return urlPrefix />
</#function>

<#--
	Macro getLayoutFriendlyUrl
	Parameter linkToPage = an article structure element of the type LinkToPage
	Returns friendlyURL for the link.
-->
<#function getLayoutFriendlyUrl linkToPage>

  <#local linkInfo = [] />

  <#local linkLayoutFriendlyUrl = "" />

  <#if linkToPage.data?has_content>
  	<#local linkData = linkToPage.data?split("@") />

  	<#local linkLayoutId =  getterUtil.getLong(linkData[0]) />

  	<#local linkLayoutIsPrivate =  false />
  	<#if linkData[1] == "private-group">
  		<#local linkLayoutIsPrivate = true />
  	</#if>

  	<#local linkLayoutGroupId = getterUtil.getLong(linkData[2]) />

  	<#local linkLayout = layoutLocalService.getLayout(linkLayoutGroupId, linkLayoutIsPrivate, linkLayoutId) />

  	<#local linkLayoutFriendlyUrl = linkLayout.friendlyURL />

    <#local linkLayoutName = linkLayout.getName(locale) />

    <#local iconClass = "" />
    <#local iconClassExpando  = expandoValueLocalService.getValue(companyId, "com.liferay.portal.model.Layout", "CUSTOM_FIELDS", "icon-class", linkLayout.getPlid())! />
    <#if iconClassExpando?has_content>
      <#local iconClass = iconClass + "block-nav-icon block-nav-icon-" + iconClassExpando.getData() />
    </#if>

    <#local linkInfo = [linkLayoutFriendlyUrl, linkLayoutName, iconClass] />

  </#if>

	<#return linkInfo />

</#function>
