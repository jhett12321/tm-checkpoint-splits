bool pluginEnabled = true;

void Main()
{
    GUI::Initialize();
}

void Update(float dt)
{
    CP::Update();
}

void Render()
{
    auto player = GetPlayer();
    if (player !is null)
    {
        auto scriptPlayer = cast<CSmScriptPlayer@>(player.ScriptAPI);
        if (scriptPlayer !is null && scriptPlayer.Post == CSmScriptPlayer::EPost::CarDriver)
        {
            if (pluginEnabled)
            {
                GUI::Render();
            }
        }
    }
}

void RenderMenu()
{
  if (UI::MenuItem("\\$f00" + Icons::ListOl + "\\$z Checkpoint Split Overlay", "", pluginEnabled))
  {
    pluginEnabled = !pluginEnabled;
  }
}

CSmPlayer@ GetPlayer()
{
    auto app = cast<CTrackMania@>(GetApp());
    if(app is null)
    {
        return null;
    }

    auto playground = cast<CSmArenaClient@>(app.CurrentPlayground);
    if (playground is null)
    {
        return null;
    }

    if (playground.GameTerminals.Length < 1)
    {
        return null;
    }

    auto terminal = playground.GameTerminals[0];
    if (terminal is null)
    {
        return null;
    }

    return cast<CSmPlayer@>(terminal.ControlledPlayer);
}
