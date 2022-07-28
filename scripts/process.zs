# ######################################################################
#
# process.zs
#
# Collects all machines's functions in one place
# using:
#   scripts.process.{action}([args]);
#
# Variable "exceptions" tells what machines should be excluded from adding recipes,
#   case unsensetive. Also can be reverted with keyword "only:" from left.
#   See functions body to see machine names.
#   Keyword "strict:" try to remove old recipe before add new (replacing recipe)
#   Warning: only few machines have "strict" functions. See processWork.zs for more info
#
# - "exceptions" variable examples:
# "macerator"                - recipe will me added in all machines except Macerator
# "MaceRATor"                - same as above
# "Except: Macerator oh my"  - same as above
# "macerator, SagMill"       - recipe will me added in all machines except Macerator and SagMill
# "only: Macerator"          - recipe will be added to Macerator only
# "only: Macerator SagMill"  - recipe will be added to Macerator and SagMill only
# "strict: manufactory"      - recipe will be added to Manufactory only, but removed old recipe first
# "maceratorSagMill"         - wrong, words should be delimited with word boundrys
# "only: blockCutter strict: shapeless" - added to blockCutter and shapeless,
#    but shapeless would be removed first
#
# ######################################################################


import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;
import crafttweaker.item.WeightedItemStack;
import crafttweaker.oredict.IOreDict;
import crafttweaker.oredict.IOreDictEntry;
import crafttweaker.liquid.ILiquidStack;
import crafttweaker.data.IData;

import scripts.processWork.work;
import scripts.processWork.workEx;

#priority 50

# ######################################################################
#
# Helpers
#
# ######################################################################

# Multiply item amount on double value
function iF(output as IItemStack, mult as double) as IItemStack  {
  if (isNull(output)) { return null; }
  return output * max(1, min(output.maxStackSize, (output.amount as double * mult) as int));
}

# Multiply liquid amount on double value
function lF(output as ILiquidStack, mult as double) as ILiquidStack  {
  if (isNull(output)) { return null; }
  return output * ((output.amount as double * mult) as int);
}

# ######################################################################
#
# Aliases functions
#
# ######################################################################


# Use sawblade to split item into pieces
# Extra is optional
# 📦 → 📦
function sawExtra(input as IIngredient, output as IItemStack, extra as IItemStack, extraChance as float, exceptions as string) {
  
  work(["shapeless", "BlockCutter", "mekSawmill", "manufactory", "TESawmill", "AdvRockCutter"],
    exceptions, [input], null, [output], null, [extra], [extraChance]);
}

# Use sawblade to split item into pieces
# 📦 → 📦
function saw(input as IIngredient, output as IItemStack, exceptions as string) {
  sawExtra(input, output, null, 0, exceptions);
}

# Takes Wood Log and saw it
# Item amount recalculated automatically
# Always output one type of wood dust
# 📦 → 📦
function sawWood(input as IIngredient, output as IItemStack, exceptions as string) {

  val pulp = <ore:dustWood>.firstItem;
  
  work(["shapeless"],    exceptions, [input], null, [output * 2], null, [pulp], null);
  work(["BlockCutter"],  exceptions, [input], null, [output * 4], null, [pulp], null);
  work(["mekSawmill"],   exceptions, [input], null, [output * 4], null, [pulp], null);
  work(["manufactory"],  exceptions, [input], null, [output * 5], null, [pulp], null);
  work(["TESawmill"],    exceptions, [input], null, [output * 6], null, [pulp], null);
  work(["AdvRockCutter"],exceptions, [input], null, [output *10], null, [pulp], null);
}

# Crush (grind) item to get it dusts and byproducts
# 📦 → 📦 + [📦]?
function crush(input as IIngredient, output as IItemStack, exceptions as string, extra as IItemStack[], extraChance as float[]) {
  
  work([
    "manufactory" , "Macerator"  , "eu2Crusher"        ,
    "AACrusher"   , "IECrusher"  , "SagMill"           ,
    "Grindstone"  , "AEGrinder"  , "ThermalCentrifuge" ,
    "Pulverizer"  , "mekCrusher"
  ],exceptions, [input], null, [output], null, extra, extraChance);
}

# Compress item to another
# 📦 → 📦
function compress(input as IIngredient, output as IItemStack, exceptions as string) {
  
  work(["Pressurizer", "Compressor", "Compactor"], exceptions, [input], null, [output], null, null, null);
}

# Extract item from another
# 📦 → 📦
function extract(input as IIngredient, output as IItemStack, exceptions as string) {
  
  work(["extractor"],    exceptions, [input], null, [output], null, null, null);
}

# Alloy two or more metals into one
# [📦+] → 📦
function alloy(input as IIngredient[], output as IItemStack, exceptions as string) {
  
  work(["alloyFurnace", "induction", "alloySmelter", "arcFurnance", "AdvRockArc"],
    exceptions, input, null, [output], null, null, null);
}

# Takes plant or seed and grow it
# 📦 → 📦 + 📦?
function grow(input as IIngredient, output as IItemStack, exceptions as string, 
      secondaryOutput as IItemStack, secondaryChance as float) {

  workEx("Insolator", exceptions, [input, <thermalfoundation:fertilizer>  ], null, [iF(output, 0.333f)], null, [secondaryOutput], [secondaryChance], {energy: 4800});
  workEx("Insolator", exceptions, [input, <thermalfoundation:fertilizer:1>], null, [iF(output, 0.666f)], null, [secondaryOutput], [secondaryChance], {energy: 7200});
  workEx("Insolator", exceptions, [input, <thermalfoundation:fertilizer:2>], null, [output            ], null, [secondaryOutput], [secondaryChance], {energy: 9600});
}

# Crushing rocks (like granite, andesite, etc..) to obtain dusts
# 📦 → [📦📦📦]
function crushRock(input as IIngredient, output as IItemStack[], exceptions as string) {
  
  work(["rockCrusher"], exceptions, [input], null, output, null, null, null);
}

# Takes soft or moist item, squeeze it to get liquid or another item
# 📦 → 💧? + 📦?
function squeeze(input as IIngredient, fluidOutput as ILiquidStack, exceptions as string, itemOutput as IItemStack) {
  
  work(["CrushingTub"],         exceptions, [input], null, [iF(itemOutput, 0.5d)],  [lF(fluidOutput, 0.5d)],      null, null);
  work(["Squeezer"],            exceptions, [input], null, [iF(itemOutput, 0.5d)],  [lF(fluidOutput, 0.666666d)], null, null);
  work(["MechanicalSqueezer"],  exceptions, [input], null, [iF(itemOutput, 0.5d)],  [lF(fluidOutput, 0.75d)],     null, null);
  work(["ForestrySqueezer"],    exceptions, [input], null, [iF(itemOutput, 0.5d)],  [lF(fluidOutput, 0.9d)],      null, null);
  work(["TECentrifuge"],        exceptions, [input], null, [iF(itemOutput, 0.75d)], [fluidOutput], null, null);
  work(["IndustrialSqueezer"],  exceptions, [input], null, [itemOutput], [fluidOutput], null, null);
  work(["FluidExtractor"],      exceptions, [input], null, [itemOutput], [fluidOutput], null, null);
}

# Solute (mix, dissolve) 1+ items in 1+ liquids to get new 1+ liquids
# [📦+] ⤵
#         [💧+]
# [💧+]  ⤴
function solution(inputItems as IIngredient[], inputLiquids as ILiquidStack[], outputLiquids as ILiquidStack[], inputChance as float[], exceptions as string) {

  work(["vat", "canner", "fluidenricher", "ChemicalReactor"], 
    exceptions, inputItems, inputLiquids, null, outputLiquids, null, inputChance);
}

# Electrolyze
# 💧 → [💧+]
function electrolyze(inputLiquid as ILiquidStack, outputLiquids as ILiquidStack[], exceptions as string) {

  work(["NCelectrolyzer", "AdvRockElectrolyzer"], exceptions, null, [inputLiquid], null, outputLiquids, null, null);
  
  # Temporary disabled during IC2 Tweaker bug
  # work(["ic2electrolyzer"],    exceptions, null, [inputLiquid], null, outputLiquids, null, null);
}

# Evaporate (dry) liquid to leave precipitate
# 💧 → 📦
function evaporate(inputLiquid as ILiquidStack, output as IItemStack, exceptions as string) {
    
  work(["EvaporatingBasin"],      exceptions, null, [inputLiquid], [iF(output, 0.5d)],  null, null, null);
  work(["DryingBasin"],           exceptions, null, [inputLiquid], [iF(output, 0.75d)], null, null, null);
  work(["MechanicalDryingBasin"], exceptions, null, [inputLiquid], [iF(output, 1.0d)],  null, null, null);
}

# Perform recycling on item made from metal
# Output can be liquid or item form, based on machine
# 📦 → 📦|💧
function recycleMetal(input as IIngredient, output as IItemStack, liquid as ILiquidStack, exceptions as string) {
  
  work(["arcFurnance"], exceptions, [input], null, [output], null, null, null);
  work(["induction"],   exceptions, [input, <minecraft:sand>], null, [output], null, [itemUtils.getItem("thermalfoundation:material",864)], [0.1f]);
  work(["smeltery"],    exceptions, [input], null, [output], [lF(liquid, 0.75d)], null, null);
}

# Melts item in liquid form
# 📦 → 💧
function melt(input as IIngredient, output as ILiquidStack, exceptions as string) {
  
  work(["smeltery", "melter"],   exceptions, [input], null, null, [output], null, null);
}

# Fill an item with liquid
# 📦 ⤵
#     📦
# 💧  ⤴
function fill(itemInput as IIngredient, fluidInput as ILiquidStack, output as IItemStack, exceptions as string) {
  
  val newAmount1 = min(1000, (fluidInput.amount as double * 1.6d) as int);
  val newAmount2 = min(1000, (fluidInput.amount as double * 1.4d) as int);
  work(["Casting"],                exceptions, [itemInput], [lF(fluidInput, 1.8d)], [output], null, null, null);
  work(["DryingBasin"],            exceptions, [itemInput], [fluidInput * newAmount1], [output], null, null, null);
  work(["MechanicalDryingBasin"],  exceptions, [itemInput], [fluidInput * newAmount2], [output], null, null, null);
  work(["NCInfuser"],              exceptions, [itemInput], [lF(fluidInput, 1.2d)], [output], null, null, null);
}