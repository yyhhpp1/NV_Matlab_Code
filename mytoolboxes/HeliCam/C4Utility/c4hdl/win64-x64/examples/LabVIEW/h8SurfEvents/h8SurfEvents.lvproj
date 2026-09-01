<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="15008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="libC4HdlLV.lvlib" Type="Library" URL="../../../../../../../../Program Files/C4Utility/c4hdl/win64-x64/LabVIEW/libC4HdlLV.lvlib"/>
		<Item Name="main.vi" Type="VI" URL="../main.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Trim Whitespace.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Trim Whitespace.vi"/>
				<Item Name="whitespace.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/whitespace.ctl"/>
			</Item>
			<Item Name="C4HdlCLR" Type="VI" URL="C4HdlCLR">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="libC4HdlLV_simple" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{0C2AD11B-66E1-4B6C-9267-FDAA5AA98E7F}</Property>
				<Property Name="App_INI_GUID" Type="Str">{9A1FD3C6-4AFB-4BC9-8452-EE174CC5B427}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_autoIncrement" Type="Bool">true</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{8970B9C0-059F-4102-A29B-04F7A0827EE8}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">libC4HdlLV_simple</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/NI_AB_PROJECTNAME/libC4HdlLV_simple</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{6383C5B5-8B3E-49F5-A872-2EC401926919}</Property>
				<Property Name="Bld_version.build" Type="Int">11</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">libC4HdlLV_simple.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/NI_AB_PROJECTNAME/libC4HdlLV_simple/libC4HdlLV_simple.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/NI_AB_PROJECTNAME/libC4HdlLV_simple/data</Property>
				<Property Name="Destination[2].destName" Type="Str">sharedLibrary</Property>
				<Property Name="Destination[2].path" Type="Path">../builds/NI_AB_PROJECTNAME/libC4HdlLV_simple</Property>
				<Property Name="DestinationCount" Type="Int">3</Property>
				<Property Name="Source[0].itemID" Type="Str">{8EE350FB-98DA-4957-B4C3-4CA735B531F7}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/main.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].destinationIndex" Type="Int">1</Property>
				<Property Name="Source[2].itemID" Type="Ref">/</Property>
				<Property Name="Source[2].preventRename" Type="Bool">true</Property>
				<Property Name="SourceCount" Type="Int">3</Property>
				<Property Name="TgtF_companyName" Type="Str">Heliotis AG</Property>
				<Property Name="TgtF_fileDescription" Type="Str">libC4HdlLV_simple</Property>
				<Property Name="TgtF_internalName" Type="Str">libC4HdlLV_simple</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2020 Heliotis AG</Property>
				<Property Name="TgtF_productName" Type="Str">libC4HdlLV_simple</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{B1F298E1-C933-46B0-8662-7555FF199FC1}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">libC4HdlLV_simple.exe</Property>
			</Item>
		</Item>
	</Item>
</Project>
