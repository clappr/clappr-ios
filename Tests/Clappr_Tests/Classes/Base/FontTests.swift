import Quick
import Nimble
import CoreMedia
import AVKit
@testable import Clappr

class FontTests: QuickSpec {
    
    override func spec() {
        
        // MARK: - Aligment
        
        describe("Aligment") {
            context(".start") {
                it("should the value be equal to kCMTextMarkupAlignmentType_Start") {
                    let aligment: Alignment = .start
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Start)))
                }
            }
            
            context(".middle") {
                it("should the value be equal to kCMTextMarkupAlignmentType_Middle") {
                    let aligment: Alignment = .middle
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Middle)))
                }
            }
            
            context(".end") {
                it("should the value be equal to kCMTextMarkupAlignmentType_End") {
                    let aligment: Alignment = .end
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_End)))
                }
            }
            
            context(".left") {
                it("should the value be equal to kCMTextMarkupAlignmentType_Left") {
                    let aligment: Alignment = .left
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Left)))
                }
            }
            
            context(".right") {
                it("should the value be equal to kCMTextMarkupAlignmentType_Right") {
                    let aligment: Alignment = .right
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Right)))
                }
            }
        }
        
        // MARK: - Direction
        
        describe("Direction") {
            context(".ltr") {
                it("should the value be equal to kCMTextVerticalLayout_LeftToRight") {
                    let direction: Direction = .ltr
                    expect(direction.value).to(equal(String(kCMTextVerticalLayout_LeftToRight)))
                }
            }
            
            context(".rtl") {
                it("should the value be equal to kCMTextVerticalLayout_RightToLeft") {
                    let direction: Direction = .rtl
                    expect(direction.value).to(equal(String(kCMTextVerticalLayout_RightToLeft)))
                }
            }
        }
        
        // MARK: - EdgeStyle
        
        describe("EdgeStyle") {
            context(".none") {
                it("should the value be equal to kCMTextMarkupCharacterEdgeStyle_None") {
                    let edgeStyle: EdgeStyle = .none
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_None))
                }
            }
            
            context(".raised") {
                it("should the value be equal to kCMTextMarkupCharacterEdgeStyle_Raised") {
                    let edgeStyle: EdgeStyle = .raised
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_Raised))
                }
            }
            
            context(".depressed") {
                it("should the value be equal to kCMTextMarkupCharacterEdgeStyle_Depressed") {
                    let edgeStyle: EdgeStyle = .depressed
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_Depressed))
                }
            }
            
            context(".uniform") {
                it("should the value be equal kCMTextMarkupCharacterEdgeStyle_Uniform") {
                    let edgeStyle: EdgeStyle = .uniform
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_Uniform))
                }
            }
            
            context(".dropShadow") {
                it("should the value be equal kCMTextMarkupCharacterEdgeStyle_DropShadow") {
                    let edgeStyle: EdgeStyle = .dropShadow
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_DropShadow))
                }
            }
        }
        
        // MARK: - Font
        
        describe("Font") {
            context(".custom") {
                it("should the value be equal CleanSans and the key equal kCMTextMarkupAttribute_FontFamilyName") {
                    let fontCustom: Font = .custom("ClearSans")
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_FontFamilyName)))
                    expect(fontCustom.value).to(equal("ClearSans"))
                }
            }
            
            context(".default") {
                it("should the value be equal kCMTextMarkupGenericFontName_Default and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .default
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Default)))
                }
            }
            
            context(".serif") {
                it("should the value be equal kCMTextMarkupGenericFontName_Serif and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .serif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Serif)))
                }
            }
            
            context(".sansSerif") {
                it("should the value be equal kCMTextMarkupGenericFontName_SansSerif and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .sansSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_SansSerif)))
                }
            }
            
            context(".monospace") {
                it("should the value be equal kCMTextMarkupGenericFontName_Monospace and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .monospace
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Monospace)))
                }
            }
            
            context(".proportionalSerif") {
                it("should the value be equal kCMTextMarkupGenericFontName_ProportionalSerif and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .proportionalSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_ProportionalSerif)))
                }
            }
            
            context(".proportionalSansSerif") {
                it("should the value be equal kCMTextMarkupGenericFontName_ProportionalSansSerif and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .proportionalSansSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_ProportionalSansSerif)))
                }
            }
            
            context(".monospaceSerif") {
                it("should the value be equal kCMTextMarkupGenericFontName_MonospaceSerif and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .monospaceSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_MonospaceSerif)))
                }
            }
            
            context(".monospaceSansSerif") {
                it("should the value be equal kCMTextMarkupGenericFontName_MonospaceSansSerif and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .monospaceSansSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_MonospaceSansSerif)))
                }
            }
            
            context(".casual") {
                it("should the value be equal kCMTextMarkupGenericFontName_Casual and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .casual
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Casual)))
                }
            }
            
            context(".cursive") {
                it("should the value be equal kCMTextMarkupGenericFontName_Cursive and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .cursive
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Cursive)))
                }
            }
            
            context(".fantasy") {
                it("should the value be equal kCMTextMarkupGenericFontName_Fantasy and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .fantasy
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Fantasy)))
                }
            }
            
            context(".smallCapital") {
                it("should the value be equal kCMTextMarkupGenericFontName_SmallCapital and the key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .smallCapital
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_SmallCapital)))
                }
            }
        }
        
        // MARK: - TextStyle
        
        describe("TextStyle") {
            context(".characterBackground") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_CharacterBackgroundColorARGB and the value be equal to [1, 1, 1, 1]") {
                    let style: TextStyle = .characterBackground(.white)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_CharacterBackgroundColorARGB) : [1.0, 1.0, 1.0, 1.0]])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_CharacterBackgroundColorARGB)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".background") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_BackgroundColorARGB and the value be equal to [1, 1, 1, 1]") {
                    let style: TextStyle = .background(.white)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_BackgroundColorARGB) : [1.0, 1.0, 1.0, 1.0]])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_BackgroundColorARGB)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".foreground") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_ForegroundColorARGB and the value be equal to [1, 1, 1, 1]") {
                    let style: TextStyle = .foreground(.red)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_ForegroundColorARGB) : [1.0, 1.0, 0, 0]])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_ForegroundColorARGB)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".fontSize") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight and the value be equal to 12") {
                    let style: TextStyle = .fontSizePercentage(12)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight) : 12])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".bold") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_BoldStyle and the value be equal to true") {
                    let style: TextStyle = .bold
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_BoldStyle) : true])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_BoldStyle)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".underline") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_UnderlineStyle and the value be equal to true") {
                    let style: TextStyle = .underline
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_UnderlineStyle) : true])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_UnderlineStyle)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".italic") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_ItalicStyle and the value be equal to true") {
                    let style: TextStyle = .italic
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_ItalicStyle) : true])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_ItalicStyle))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".edge") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_CharacterEdgeStyle and the value be equal to kCMTextMarkupCharacterEdgeStyle_DropShadow") {
                    let style: TextStyle = .edge(.dropShadow)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_CharacterEdgeStyle) : kCMTextMarkupCharacterEdgeStyle_DropShadow])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_CharacterEdgeStyle))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".alignment") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_Alignment and the value be equal to kCMTextMarkupAlignmentType_Left") {
                    let style: TextStyle = .alignment(.left)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_Alignment) : kCMTextMarkupAlignmentType_Left])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_Alignment))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".direction") {
                it("should the value be equal an AVTextStyleRyle with the key equal to kCMTextMarkupAttribute_VerticalLayout and the value be equal to kCMTextVerticalLayout_LeftToRight") {
                    let style: TextStyle = .direction(.ltr)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_VerticalLayout) : kCMTextVerticalLayout_LeftToRight])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_VerticalLayout))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
        }
        
        // MARK: - AVPlayerItem
        
        describe("AVPlayerItem") {
            context(".textStyleRule") {
                it("should the default value be nil") {
                    let currentItem = AVPlayerItem(url: URL(fileURLWithPath: ""))
                    expect(currentItem.textStyleRules).to(beNil())
                }

                it("should the value be equal a map from 'textStyle' to an array of AVTextStyleRule") {
                    let currentItem = AVPlayerItem(url: URL(fileURLWithPath: ""))
                    currentItem.textStyle = [
                        .alignment(.left),
                        .background(.white),
                        .bold,
                        .characterBackground(.red),
                        .direction(.ltr),
                        .edge(.dropShadow),
                        .font(.casual),
                        .fontSizePercentage(12),
                        .foreground(.blue),
                        .italic,
                        .underline
                    ]
                    
                    let expectedValue = [
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_Alignment)) : (kCMTextMarkupAlignmentType_Left)]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_BackgroundColorARGB)) : [1.0, 1.0, 1.0, 1.0]]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_BoldStyle)) : true]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_CharacterBackgroundColorARGB)) : [1.0, 1.0, 0, 0]]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_VerticalLayout)) : (kCMTextVerticalLayout_LeftToRight)]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_CharacterEdgeStyle)) : kCMTextMarkupCharacterEdgeStyle_DropShadow]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_GenericFontFamilyName)) : kCMTextMarkupGenericFontName_Casual]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight)) : 12]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_ForegroundColorARGB)) : [1.0, 0, 0, 1.0]]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_ItalicStyle)) : true]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_UnderlineStyle)) : true])
                    ]
                    
                    expect(currentItem.textStyleRules).to(equal(expectedValue))
                }
            }
        }
    }
}
