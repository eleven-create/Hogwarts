// InkBridge.cs
// 职责：让 GDScript 能方便地创建 InkStory 实例
// 关键修复：直接 new InkStory()，通过 RawStory 属性 setter 触发 InitializeRuntimeStory()
//          绕开 InkStory.Create() 的 bug（它用字段赋值绕过了 setter）
using Godot;
using GodotInk;
using Ink;
using System.Reflection;

namespace HarryPotter;

[GlobalClass]
public partial class InkBridge : RefCounted
{
    private static PropertyInfo _rawStoryProp;

    static InkBridge()
    {
        _rawStoryProp = typeof(InkStory).GetProperty(
            "RawStory",
            BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public
        );
    }

    /// <summary>
    /// 从 .ink 文件加载并编译，返回可用的 InkStory
    /// </summary>
    public static InkStory CreateStoryFromFile(string inkFilePath)
    {
        if (!FileAccess.FileExists(inkFilePath))
        {
            GD.PushError($"[InkBridge] Ink 文件不存在: {inkFilePath}");
            return null;
        }
        var file = FileAccess.Open(inkFilePath, FileAccess.ModeFlags.Read);
        string rawText = file.GetAsText();
        file.Close();
        return CreateStoryFromText(rawText);
    }

    /// <summary>
    /// 从 .ink 源码编译并创建 InkStory
    /// </summary>
    public static InkStory CreateStoryFromText(string rawInkSource)
    {
        if (string.IsNullOrEmpty(rawInkSource))
        {
            GD.PushError("[InkBridge] Ink 源码为空");
            return null;
        }
        try
        {
            // 编译 .ink → JSON
            var compiler = new Compiler(rawInkSource, new Compiler.Options
            {
                countAllVisits = true,
                sourceFilename = "res://ink/main.ink",
            });
            string jsonContent = compiler.Compile().ToJson();
            GD.Print($"[InkBridge] 编译完成: {rawInkSource.Length} → {jsonContent.Length} 字符");

            // 用 JSON 创建 InkStory
            return CreateStoryFromJson(jsonContent);
        }
        catch (System.Exception e)
        {
            GD.PushError($"[InkBridge] 编译失败: {e.Message}");
            return null;
        }
    }

    /// <summary>
    /// 从已编译的 JSON 创建 InkStory
    /// </summary>
    public static InkStory CreateStoryFromJson(string jsonContent)
    {
        if (string.IsNullOrEmpty(jsonContent))
        {
            GD.PushError("[InkBridge] JSON 为空");
            return null;
        }
        if (_rawStoryProp == null)
        {
            GD.PushError("[InkBridge] 找不到 InkStory.RawStory 属性");
            return null;
        }
        // 关键修复：new InkStory() + 通过 RawStory 属性 setter 触发 InitializeRuntimeStory()
        var story = new InkStory();
        _rawStoryProp.SetValue(story, jsonContent);
        GD.Print($"[InkBridge] InkStory 创建成功 ({jsonContent.Length} 字符)");
        return story;
    }
}
