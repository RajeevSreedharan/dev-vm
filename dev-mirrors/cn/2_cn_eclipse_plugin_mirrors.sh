cat << EOF >> /home/dev-rajeev/.gradle/init.gradle 
allprojects{
    repositories {
        def ALIYUN_REPOSITORY_URL = 'http://maven.aliyun.com/nexus/content/groups/public'
        def ALIYUN_JCENTER_URL = 'http://maven.aliyun.com/nexus/content/repositories/jcenter'
        all { ArtifactRepository repo ->
            if(repo instanceof MavenArtifactRepository){
                def url = repo.url.toString()
                if (url.startsWith('https://repo1.maven.org/maven2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_REPOSITORY_URL."
                    remove repo
                }
                if (url.startsWith('https://jcenter.bintray.com/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_JCENTER_URL."
                    remove repo
                }
            }
        }
        maven {
                url ALIYUN_REPOSITORY_URL
            url ALIYUN_JCENTER_URL
        }
    }
}
EOF


mkdir /home/dev-rajeev/.m2
cat << EOF >> /home/dev-rajeev/.m2/settings.xml
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
	<mirrors>
		<!-- mirror | Specifies a repository mirror site to use instead of a given 
			repository. The repository that | this mirror serves has an ID that matches 
			the mirrorOf element of this mirror. IDs are used | for inheritance and direct 
			lookup purposes, and must be unique across the set of mirrors. | -->
		<mirror>
			<id>nexus-osc</id>
			<mirrorOf>central</mirrorOf>
			<name>Nexus osc</name>
			<url>http://maven.oschina.net/content/groups/public/</url>
		</mirror>
		<mirror>
			<id>nexus-osc-thirdparty</id>
			<mirrorOf>thirdparty</mirrorOf>
			<name>Nexus osc thirdparty</name>
			<url>http://maven.oschina.net/content/repositories/thirdparty/</url>
		</mirror>
	</mirrors>

	<profiles>
		<profile>
			<id>default</id>
			<repositories>
				<repository>
					<id>nexus</id>
					<name>local private nexus</name>
					<url>http://maven.oschina.net/content/groups/public/</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
				</repository>
			</repositories>
			<pluginRepositories>
				<pluginRepository>
					<id>nexus</id>
					<name>local private nexus</name>
					<url>http://maven.oschina.net/content/groups/public/</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
				</pluginRepository>
			</pluginRepositories>
		</profile>
	</profiles>
</settings>
EOF
