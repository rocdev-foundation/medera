defmodule Medera.Minion.SkillTest do
  use ExUnit.Case

  @skill_path Path.expand("../../fixture/skills", __DIR__)

  alias Medera.Minion.Skill

  test "loading a skill map from a file" do
    map = Skill.load_map!(Path.join(@skill_path, "test_skills.json"))
    assert %Skill{
      description: "Show drive usage",
      verb: "df",
      noun: "/",
      command: "df -h /",
      node: Node.self()
    } == map["df-/"]
  end

  test "building the command invocation" do
    skill = %Skill{verb: "do", noun: "things"}
    assert "do-things" == Skill.invocation(skill)
  end

  test "node has intrinsic skills when no file specified" do
    skills = Skill.load!(nil)
    assert length(skills) > 0
  end
end
