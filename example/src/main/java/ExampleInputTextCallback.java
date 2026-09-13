import imgui.moulberry90.ImGui;
import imgui.moulberry90.ImGuiInputTextCallbackData;
import imgui.moulberry90.callback.ImGuiInputTextCallback;
import imgui.moulberry90.flag.ImGuiCond;
import imgui.moulberry90.flag.ImGuiInputTextFlags;
import imgui.moulberry90.type.ImBoolean;
import imgui.moulberry90.type.ImString;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ExampleInputTextCallback {
    private static final ImString STR = new ImString();
    private static final StringBuilder OUTPUT = new StringBuilder();
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");

    private static final ImGuiInputTextCallback CALLBACK = new ImGuiInputTextCallback() {
        @Override
        public void accept(final ImGuiInputTextCallbackData data) {
            final char c = (char) data.getEventChar();
            if (c == 'h' || c == 'H') {
                data.setEventChar('!');
                OUTPUT.append(DATE_FORMAT.format(LocalDateTime.now())).append(" :: Replaced!\n");
            } else if (c == 'w' || c == 'W') {
                data.setEventChar(0);
                OUTPUT.append(DATE_FORMAT.format(LocalDateTime.now())).append(" :: Discarded!\n");
            } else {
                OUTPUT.append(DATE_FORMAT.format(LocalDateTime.now())).append(" :: Typed: ").append(c).append('\n');
            }
        }
    };

    public static void show(final ImBoolean showInputTextCallback) {
        ImGui.setNextWindowSize(400, 300, ImGuiCond.Once);
        if (ImGui.begin("Input Text Callback Demo", showInputTextCallback)) {
            ImGui.alignTextToFramePadding();
            ImGui.text("Try to input \"Hello World!\":");
            ImGui.sameLine();
            ImGui.inputText("##input", STR, ImGuiInputTextFlags.CallbackCharFilter, CALLBACK);
            ImGui.text(OUTPUT.toString());
        }
        ImGui.end();
    }
}
