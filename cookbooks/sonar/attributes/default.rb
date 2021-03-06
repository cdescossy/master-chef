default[:sonar][:location] = "/sonar"
default[:sonar][:version] = "3.7.4"
default[:sonar][:zip_url] = "http://dist.sonar.codehaus.org/sonar-#{default[:sonar][:version]}.zip"
default[:sonar][:path] = "/opt/sonar"
default[:sonar][:tomcat] = {
  :name => 'sonar',
  :env => {
    'JAVA_OPTS' => '-XX:MaxPermSize=512m -Xmx1024m -Xms256m',
  }
}
default[:sonar][:database] = {
  :host => 'localhost',
  :username => 'sonar',
  :database => 'sonar',
}
