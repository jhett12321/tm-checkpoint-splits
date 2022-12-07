/*
 * Based on GUI.as by RuteNL
 * v1.0.2
 * https://github.com/RuurdBijlsma/tm-split-speeds/blob/master/src/GUI.as
 */

namespace GUI
{
    vec4 sameTimeColour = vec4(.5, .5, .5, .75);
    vec4 shadowColour = vec4(0, 0, 0, .6);
    vec4 fasterColour = vec4(0, .123, .822, .75);
    vec4 slowerColour = vec4(.869, 0.117, 0.117, .784);

    bool textShadow = false;
    float scale = 1;

    [Setting name="X position" min=0 max=1 category="General"]
    float anchorX = .5;

    [Setting name="Y position" min=0 max=1 category="General"]
    float anchorY = .325;
    
    [Setting name="Show when HUD is visible" min=0 max=1 category="General"]
    bool showWithHudVisible= false;
    
    [Setting name="Show when HUD is hidden" min=0 max=1 category="General"]
    bool showWithHudHidden = true;

    vec4 textBgColour = vec4(0, 0, 0, 0.867);
    vec4 textColour = vec4(1, 1, 1, 1);

    int font;

    int shadowX = 1;
    int shadowY = 1;
    int fontSize = 34;

    string raceTimeText;
    string diffTimeText;
    uint showTime = 0;

    void Initialize()
    {
	    font = nvg::LoadFont("Oswald-Regular.ttf");
    }

    void CheckpointUpdate()
    {
        showTime = Time::Now;
        UpdateTimes();
    }

    void Render()
    {
        bool hudVisible = UI::IsGameUIVisible();
        
        if(hudVisible && !showWithHudVisible)
        {
            return;
        }

        if(!hudVisible && !showWithHudHidden)
        {
            return;
        }
    
        if (showTime + 3000 <= Time::Now)
        {
            raceTimeText = "";
            diffTimeText = "";
            return;
        }

        float h = float(Draw::GetHeight());
        float w = float(Draw::GetWidth());
        float scaleX, scaleY, offsetX = 0;
        if(w / h > 16. / 9) {
            auto correctedW = (h / 9.) * 16;
            scaleX = correctedW / 2560;
            scaleY = h / 1440;
            offsetX = (w - correctedW) / 2;
        } else {
            scaleX = w / 2560;
            scaleY = h / 1440;
        }

        nvg::Save();
        nvg::Translate(offsetX, 0);
        nvg::Scale(scaleX, scaleY);
        RenderDefaultUI();
        nvg::Restore();
    }

    void RenderDefaultUI()
    {
        uint boxWidth = uint(scale * 170);
        uint boxHeight = uint(scale * 57);
        uint padding = 7;
        uint x = uint(anchorX * 2560 - boxWidth / 2);
        uint y = uint(anchorY * 1440 - boxHeight / 2);
        uint textOffsetY = 0;
        nvg::FontFace(font);

        nvg::FontSize(scale * fontSize);
        textOffsetY = 3;

        // Draw current time
        // Draw box
        nvg::BeginPath();
        nvg::Rect(x, y - boxHeight, boxWidth, boxHeight);
        nvg::FillColor(textBgColour);
        nvg::Fill();
        nvg::ClosePath();
        // Draw text
        nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);
        nvg::FillColor(textColour);
        nvg::TextBox(x - padding, y + (boxHeight / 2) + textOffsetY - boxHeight, boxWidth, raceTimeText);

        // Draw difference
        if(diffTimeText == "")
        {
            return;
        }

        // Draw box
        nvg::BeginPath();
        nvg::Rect(x, y, boxWidth, boxHeight);

        vec4 boxColour;
        if(diffTimeText.StartsWith("+"))
        {
            boxColour = slowerColour;
        }
        else if(diffTimeText.StartsWith("-"))
        {
            boxColour = fasterColour;
        }
        else
        {
            boxColour = sameTimeColour;
        }

        nvg::FillColor(boxColour);
        nvg::Fill();
        nvg::ClosePath();
        // Draw text
        nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);
        nvg::FillColor(textColour);
        nvg::TextBox(x - padding, y + boxHeight / 2 + textOffsetY, boxWidth, diffTimeText);
    }

    void UpdateTimes()
    {
        auto app = cast<CTrackMania>(GetApp());
        auto loadMgr = app.LoadProgress;
        auto network = cast<CTrackManiaNetwork>(app.Network);

        if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.UILayers.Length > 0)
        {
            auto uilayers = network.ClientManiaAppPlayground.UILayers;

            for (uint i = 0; i < uilayers.Length; i++)
            {
                CGameUILayer@ curLayer = uilayers[i];
                int start = curLayer.ManialinkPageUtf8.IndexOf("<");
                int end = curLayer.ManialinkPageUtf8.IndexOf(">");

                if (start != -1 && end != -1)
                {
                    auto manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
                    if (manialinkname.Contains("UIModule_Race_Checkpoint"))
                    {
                        auto raceTimeLabel = cast<CGameManialinkLabel@>(curLayer.LocalPage.GetFirstChild("label-race-time"));
                        auto diffTimeLabel = cast<CGameManialinkLabel@>(curLayer.LocalPage.GetFirstChild("label-race-diff"));
                        raceTimeText = raceTimeLabel.Value;
                        diffTimeText =  diffTimeLabel.Value;
                    }
                }
            }
        }
    }
}
