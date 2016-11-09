<#setting locale = locale>

<#-- Define services -->
<#assign groupLocalService = serviceLocator.findService("com.liferay.portal.service.GroupLocalService") />
<#assign layoutLocalService = serviceLocator.findService("com.liferay.portal.service.LayoutLocalService") />
<#assign layoutSetLocalService = serviceLocator.findService("com.liferay.portal.service.LayoutSetLocalService") />

<#-- Define some variables -->
<#assign urlPrefix =  getUrlPrefix(request) />

<#if navigationItems.siblings?size gt 0>
	<nav class="gb-tabs">
    <ul class="tabs-list">
  		<#list navigationItems.siblings as navigationItem>

				<#assign linkUrl = "" />
				<#assign linkText = "" />
				<#assign isCurrentLayout = false />

        <#assign linkInfo = getLayoutFriendlyUrl(navigationItem) />
        <#if linkInfo?has_content>
          <#assign linkUrl = urlPrefix + linkInfo[0] />
          <#assign linkText = linkInfo[1] />
					<#assign isCurrentLayout = linkInfo[2] />
        </#if>

				<#if navigationItem.linkText.data != "">
					<#assign linkText = navigationItem.linkText.data />
				</#if>


				<#if isCurrentLayout>
					<li class="active">
						<span class="tab">
							${linkText}
						</span>
					</li>
				<#else>
					<li>
						<a class="tab" href="${linkUrl}">
	            ${linkText}
	          </a>
					</li>
				</#if>

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

	<#local themeDisplay = request["theme-display"]! />

	<#if themeDisplay?has_content>

		<#local scopePlid =  getterUtil.getLong((themeDisplay["plid"])!) />

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

		<#local isCurrentLayout = false />
		<#local themeDisplay = request["theme-display"]! />
		<#if themeDisplay?has_content>
			<#local scopePlid =  getterUtil.getLong((themeDisplay["plid"])!) />
			<#local isCurrentLayout = (linkLayout.plid == scopePlid) />
		</#if>


    <#local linkInfo = [linkLayoutFriendlyUrl, linkLayoutName, isCurrentLayout] />

  </#if>

	<#return linkInfo />

</#function>
