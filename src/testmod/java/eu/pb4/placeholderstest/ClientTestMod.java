package eu.pb4.placeholderstest;

import eu.pb4.placeholders.api.client.ClientPlaceholderContext;
import eu.pb4.placeholders.api.parsers.NodeParser;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.TextAlignment;
import net.minecraft.client.gui.components.MultiLineLabel;
import net.minecraft.resources.Identifier;
import net.neoforged.api.distmarker.Dist;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.fml.ModContainer;
import net.neoforged.fml.common.Mod;
import net.neoforged.neoforge.client.event.RegisterGuiLayersEvent;

@Mod(value = "testmod", dist = {Dist.CLIENT})
public class ClientTestMod {
    public ClientTestMod(IEventBus modEventBus, ModContainer modContainer) {
        modEventBus.addListener(RegisterGuiLayersEvent.class, event -> {
            event.registerAboveAll(Identifier.fromNamespaceAndPath("test", "placeholders"), (guiGraphics, deltaTracker) -> {
                var parsed = NodeParser.builder().clientPlaceholders().quickText().build().parseComponent(
                        """
                                <rb>Hello world!</>
                                You are %player:head% %player:name%
                                <gr yellow gold>Position: %player:pos_x% %player:pos_y% %player:pos_z% in %player:biome%</>
                                Time: %world:time%
                                """, ClientPlaceholderContext.get().asParserContext());

                MultiLineLabel.create(Minecraft.getInstance().font, parsed).visitLines(TextAlignment.LEFT, 8, 8, 10, guiGraphics.textRenderer());
            });
        });
    }
}
