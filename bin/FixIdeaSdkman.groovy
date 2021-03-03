#!/usr/bin/env groovy

/**
 * Fixes a compatibility issue between IntelliJ IDEA, Sdkman and Azul Zulu JDK.
 *
 * The problem is Azul's packaging is slightly different and unlike the other JDKs, the JAVA_HOME
 * is at a slightly different path. Sdkman seems to handle this well by itself through symlinks.
 * However, this doesn't work well with IntelliJ.
 *
 * This script updates IntelliJ's config files to avoid the symlinks and directly point to the
 * correct path.
 */

@Grab(group = 'com.github.rahulsom', module = 'jansi-table', version = '0.3.1')
import com.github.rahulsom.jansitable.TableBuilder
import groovy.xml.XmlUtil

class FixIdeaSdkman {
	static void main(String[] args) {
		def jbHome = new File("${System.getProperty('user.home')}/Library/Application Support/JetBrains")
		println jbHome.absolutePath
		jbHome.listFiles().toList()
				.findAll { it.name.startsWith('IntelliJIdea') }
				.each { handleIntellij it }
	}

	static void handleIntellij(File intellijHome) {
		println "  ${intellijHome.name}"

		def optionsDir = new File(intellijHome, "options")
		def configFile = new File(optionsDir, "jdk.table.xml")
		if (configFile.exists()) {
			def table = new TableBuilder()
					.addColumn(15)
					.addColumn(75)
					.addColumn(40)
					.build()
			table.printHeader()
					.print("Name", "Path", "Status")
					.printDivider()
			def config = new XmlParser().parse(configFile)
			def jdks = config['component'][0].jdk
			def toRemove = []
			jdks.each { jdk ->
				def name = jdk.name[0].@value
				def home = jdk.homePath[0].@value
				if (jdk.type[0].@value == 'JavaSDK') {
					// println "    [$name] ${home}"
					def jdkHome = new File(home.replace('$USER_HOME$', System.getProperty('user.home')))
					String status = ""
					if (!jdkHome.exists()) {
						status = "[Remove]"
						toRemove << jdk
					} else {
						def hasNestedDir = jdkHome.list().find { it.matches(/zulu-\d+.jdk/) }
						if (hasNestedDir) {
							status = "[Appended] /${hasNestedDir}/Contents/Home"
							jdk.homePath[0].@value = "${home}/${hasNestedDir}/Contents/Home"
							jdk.roots[0].classPath[0].root[0].root.each { r->
								r.@url = r.@url.replace(home, "${home}/${hasNestedDir}/Contents/Home")
							}
						}
					}
					table.print(name, home, status)
				}
			}
			table.printFooter()
			XmlUtil.serialize(config, new FileWriter("${configFile.absolutePath}"))
		} else {
			println "    <No JDK Config>"
		}
	}
}
