class Cromwell < Formula
  desc "Workflow Execution Engine using Workflow Description Language"
  homepage "https://github.com/broadinstitute/cromwell"
  url "https://github.com/broadinstitute/cromwell/releases/download/0.19.3/cromwell-0.19.jar"
  version "0.19.3"
  sha256 "982f86f061b6391ffe2a05ebab193289e760b169cde1362e5cb420e1ebb2392f"

  head do
    url "https://github.com/broadinstitute/cromwell.git"
    depends_on "sbt" => :build
  end

  bottle :unneeded

  depends_on :java => "1.8+"
  depends_on "akka"

  def install
    if build.head?
      system "sbt", "assembly"
      libexec.install Dir["target/scala-*/cromwell-*.jar"][0]
      bin.write_jar_script Dir[libexec/"cromwell-*.jar"][0], "cromwell"
    else
      jar = Pathname.new(active_spec.url).basename
      libexec.install jar
      bin.write_jar_script libexec/jar, "cromwell"
    end
  end

  test do
    (testpath/"hello.wdl").write <<-EOS
      task hello {
        String name

        command {
          echo 'hello ${name}!'
        }
        output {
          File response = stdout()
        }
      }

      workflow test {
        call hello
      }
    EOS

    (testpath/"hello.json").write <<-EOS
      {
        "test.hello.name": "world"
      }
    EOS

    result = shell_output("#{bin}/cromwell run hello.wdl hello.json")

    assert_match /test\.hello\.response/, result
  end
end
