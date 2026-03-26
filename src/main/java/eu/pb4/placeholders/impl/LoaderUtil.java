package eu.pb4.placeholders.impl;

import net.neoforged.fml.loading.FMLEnvironment;

public class LoaderUtil {
    public static final boolean IS_DEV = !FMLEnvironment.isProduction();
    public static final boolean IS_CLIENT = FMLEnvironment.getDist().isClient();
}
