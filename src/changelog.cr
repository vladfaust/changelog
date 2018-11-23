require "option_parser"

# TODO: Put version

unless /([\w\.]+)\.{3}([\w\.]+)/.match(ARGV[0])
  raise ArgumentError.new("Revision range is expected, for example: changelog v0.1.0...master")
end

log = `git --no-pager log --format="{{%h}} %at %s\n%b" #{ARGV[0]}`
exit unless $?.success?

class Commit
  property hash : String
  property time : Time
  property type : String
  property scope : String?
  property subject : String?
  property body : String?

  property breaking = false

  getter closed_issues = [] of Int32
  getter fixed_issues = [] of Int32
  getter resolved_issues = [] of Int32

  def initialize(@hash, @time, @type, @scope = nil, @subject = nil, @body = nil)
  end
end

commits = {} of String => Array(Commit)
current_commit = uninitialized Commit

log.each_line do |line|
  case line
  when /^{{(?<hash>\w{7})}}/
    if /^{{(?<hash>\w{7})}} (?<timestamp>\d+) (?<type>\w+)(?:\((?<scope>\w+)\))?(?:\: (?<subject>.+))?$/ =~ line
      current_commit = Commit.new($~["hash"], Time.unix($~["timestamp"].to_i64), $~["type"], $~["scope"]?, $~["subject"]?, nil)

      (commits[current_commit.type] ||= [] of Commit) << current_commit
    end
  when /close(?:[sd])? #(\d+)/im
    $~.captures.each { |c| current_commit.closed_issues << c.not_nil!.to_i }
  when /fix(?:e[ds])? #(\d+)/im
    $~.captures.each { |c| current_commit.fixed_issues << c.not_nil!.to_i }
  when /resolve(?:[sd])? #(\d+)/im
    $~.captures.each { |c| current_commit.resolved_issues << c.not_nil!.to_i }
  when /BREAKING CHANGE/
    current_commit.breaking = true
  end
end

commits.each do |t, c|
  c.sort! { |a, b| a.time <=> b.time }
  c.sort! { |a, b| a.breaking && b.breaking ? 0 : (a.breaking ? -1 : 1) }
end

result = ""

macro log_type(_type, name)
  if commits[{{_type}}]?
    result += "### " + {{name}} + "\n"
    commits[{{_type}}].each do |commit|
      log_commit(commit)
    end
    result += "\n"
  end
end

macro log_commit(commit)
  result += "* #{commit.hash}#{" ⚠️ **breaking**" if commit.breaking} #{commit.subject}"

  if commit.closed_issues.any? || commit.fixed_issues.any? || commit.resolved_issues.any?
    result += " ("
    comma = false

    if commit.closed_issues.any?
      result += "closes " + commit.closed_issues.map{ |i| "##{i}" }.join(", ")
      comma = true
    end

    if commit.fixed_issues.any?
      result += ", " if comma
      result += "fixes " + commit.fixed_issues.map{ |i| "##{i}" }.join(", ")
      comma = true
    end

    if commit.resolved_issues.any?
      result += ", " if comma
      result += "resolves " + commit.resolved_issues.map{ |i| "##{i}" }.join(", ")
    end

    result += ")"
  end

  result += "\n"
end

log_type("feat", "New Features")
log_type("fix", "Bug Fixes")
log_type("optimize", "Optimizations")
log_type("deps", "Dependency Updates")
log_type("docs", "Documentation")
log_type("refactor", "Refactoring")
log_type("chore", "Chores")

puts result.chomp
