import os
from avulto import DMI, IconState, Dir
from PIL import Image as im
# load in a 50x50 sprite to dice up
# load in a cookie cutter mask
# xxx
# x x
# xxx
# for every cardinal dir, and inverse cardinal dir, ie just the top connected and all but the top connected
# create a new mask from just to connected dirs
# using the mask AND remove the offending tiles eg
# GGG | xxx |
# GGG &     = GGG
# GGG |     | GGG
# save it as a new dmi state with name-"bitmask"

# the suffix is a bitmask of the byond dirs
# it goes up to 255

NORTH	  = 1
SOUTH	  = 2
EAST	  = 4
WEST	  = 8
NORTHEAST = 16
SOUTHEAST = 32
NORTHWEST = 64
SOUTHWEST = 128

CURR_DIR = os.path.dirname(os.path.realpath(__file__))
PADDING = 9

path_mask = ""; path_input = ""; path_output = "";  input_state = ""; output_state = ""

def askForInput() -> None:
    global path_mask, path_input, path_output, input_state, output_state

    path_mask = input("Enter mask filepath, defaults to test_mask.dmi: ")
    if len(path_mask) == 0:
        path_mask = CURR_DIR + "\\test_mask.dmi"

    path_input = input("Enter input filepath, defaults to test_input.dmi: ")
    if len(path_input) == 0:
        path_input = CURR_DIR + "\\test_input.dmi"

    input_state = input("Enter the DMI's state to smooth, defaults to input: ")
    if len(input_state) == 0:
        input_state = "input"

    path_output = input("Enter output filepath, defaults to current directory: ")
    if len(path_output) == 0:
        path_output = CURR_DIR
    if(path_output.endswith(".dmi") == 0):
        path_output += "\\test_output.dmi"

    output_state = input("Enter the output DMIs state base name, defaults to test: ")
    if len(output_state) == 0:
        output_state = "test"

def cutFromMask(maskImg: im.Image, inputInImg: im.Image) -> im.Image:
    inputImg = inputInImg.copy()
    inputPixels = inputImg.load()
    maskPixels = maskImg.load()

    for y in range(inputImg.height):
        for x in range(inputImg.width):
             r, g, b, a = maskPixels[x, y]

             if a == 0:
                  inputPixels[x, y] = (0, 0, 0, 0)
    return inputImg

def addStateToOutput(stateImg: im.Image, outputDMI: DMI, dirs: int) -> None:
    stateData = [stateImg.tobytes()]
    width, height = stateImg.size

    newState = IconState.from_data({Dir.SOUTH: stateData}, width, height, (output_state + "-" + str(dirs)))
    outputDMI.states.append(newState)

# list of bitmask ints, 0..15 = cardinal combos
def generateMaskVariants() -> list:
    variantList = list(range(0,16))
#    for value in range(0,15):
#        variantList.append((~value) & 0xFF)
    return variantList


def createMaskVariant(mask: DMI, dirs: int) -> im.Image:
    # get the data rgba8 of the first frame of literally any dir
    maskData = mask.state("mask").data_rgba8(1, 2)
    maskImg = im.frombytes("RGBA", size=mask.icon_dims, data=maskData)
    width, height = maskImg.size

    left = PADDING if dirs & WEST else 0
    upper = PADDING if dirs & NORTH else 0
    right = width - PADDING if dirs & EAST else width
    lower = height - PADDING if dirs & SOUTH else height
    print(f"left: {left}, upper: {upper}, right: {right}, lower: {lower}")
    cropped = maskImg.crop((left, upper, right, lower))

    result = im.new("RGBA", mask.icon_dims, (0,0,0,0))
    result.paste(cropped, (left, upper))

    return result

def main():
    askForInput()

    inputDMI = DMI.from_file(path_input)
    maskDMI = DMI.from_file(path_mask)
    outputDMI = DMI.new((50,50))

    variantList = generateMaskVariants()

    inputData = inputDMI.state(input_state).data_rgba8(1,2)
    inputImg = im.frombytes("RGBA", size=inputDMI.icon_dims, data=inputData)

    for bitmask in variantList:
        maskVariantImg = createMaskVariant(maskDMI, bitmask)
        outputImg = cutFromMask(maskVariantImg, inputImg)
        addStateToOutput(outputImg, outputDMI, bitmask)

    outputDMI.save_to(path_output)
    input("Press any key to exit")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)
        input("Press any key to exit")
