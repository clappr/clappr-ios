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
                it("has value equal to kCMTextMarkupAlignmentType_Start") {
                    let aligment: Alignment = .start
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Start)))
                }
            }
            
            context(".middle") {
                it("has value equal to kCMTextMarkupAlignmentType_Middle") {
                    let aligment: Alignment = .middle
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Middle)))
                }
            }
            
            context(".end") {
                it("has value equal to kCMTextMarkupAlignmentType_End") {
                    let aligment: Alignment = .end
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_End)))
                }
            }
            
            context(".left") {
                it("has value equal to kCMTextMarkupAlignmentType_Left") {
                    let aligment: Alignment = .left
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Left)))
                }
            }
            
            context(".right") {
                it("has value equal to kCMTextMarkupAlignmentType_Right") {
                    let aligment: Alignment = .right
                    expect(aligment.value).to(equal(String(kCMTextMarkupAlignmentType_Right)))
                }
            }
        }
        
        // MARK: - Direction
        
        describe("Direction") {
            context(".ltr") {
                it("") {
                    let direction: Direction = .ltr
                    expect(direction.value).to(equal(String(kCMTextVerticalLayout_LeftToRight)))
                }
            }
            
            context(".rtl") {
                it("") {
                    let direction: Direction = .rtl
                    expect(direction.value).to(equal(String(kCMTextVerticalLayout_RightToLeft)))
                }
            }
        }
        
        // MARK: - EdgeStyle
        
        describe("EdgeStyle") {
            context(".none") {
                it("") {
                    let edgeStyle: EdgeStyle = .none
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_None))
                }
            }
            
            context(".raised") {
                let edgeStyle: EdgeStyle = .raised
                expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_Raised))
            }
            
            context(".depressed") {
                it("") {
                    let edgeStyle: EdgeStyle = .depressed
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_Depressed))
                }
            }
            
            context(".uniform") {
                it("") {
                    let edgeStyle: EdgeStyle = .uniform
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_Uniform))
                }
            }
            
            context(".dropShadow") {
                it("") {
                    let edgeStyle: EdgeStyle = .dropShadow
                    expect(edgeStyle.value).to(equal(kCMTextMarkupCharacterEdgeStyle_DropShadow))
                }
            }
        }
        
        // MARK: - Font
        
        describe("Font") {
            context(".custom") {
                it("has value equals CleanSans and key equal kCMTextMarkupAttribute_FontFamilyName") {
                    let fontCustom: Font = .custom("ClearSans")
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_FontFamilyName)))
                    expect(fontCustom.value).to(equal("ClearSans"))
                }
            }
            
            context(".default") {
                it("has value equals kCMTextMarkupGenericFontName_Default and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .default
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Default)))
                }
            }
            
            context(".serif") {
                it("has value equals kCMTextMarkupGenericFontName_Serif and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .serif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Serif)))
                }
            }
            
            context(".sansSerif") {
                it("has value equals kCMTextMarkupGenericFontName_SansSerif and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .sansSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_SansSerif)))
                }
            }
            
            context(".monospace") {
                it("has value equals kCMTextMarkupGenericFontName_Monospace and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .monospace
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Monospace)))
                }
            }
            
            context(".proportionalSerif") {
                it("has value equals kCMTextMarkupGenericFontName_ProportionalSerif and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .proportionalSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_ProportionalSerif)))
                }
            }
            
            context(".proportionalSansSerif") {
                it("has value equals kCMTextMarkupGenericFontName_ProportionalSansSerif and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .proportionalSansSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_ProportionalSansSerif)))
                }
            }
            
            context(".monospaceSerif") {
                it("has value equals kCMTextMarkupGenericFontName_MonospaceSerif and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .monospaceSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_MonospaceSerif)))
                }
            }
            
            context(".monospaceSansSerif") {
                it("has value equals kCMTextMarkupGenericFontName_MonospaceSansSerif and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .monospaceSansSerif
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_MonospaceSansSerif)))
                }
            }
            
            context(".casual") {
                it("has value equals kCMTextMarkupGenericFontName_Casual and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .casual
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Casual)))
                }
            }
            
            context(".cursive") {
                it("has value equals kCMTextMarkupGenericFontName_Cursive and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .cursive
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Cursive)))
                }
            }
            
            context(".fantasy") {
                it("has value equals kCMTextMarkupGenericFontName_Fantasy and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .fantasy
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_Fantasy)))
                }
            }
            
            context(".smallCapital") {
                it("has value equals kCMTextMarkupGenericFontName_SmallCapital and key equal kCMTextMarkupAttribute_GenericFontFamilyName") {
                    let fontCustom: Font = .smallCapital
                    
                    expect(fontCustom.key).to(equal(String(kCMTextMarkupAttribute_GenericFontFamilyName)))
                    expect(fontCustom.value).to(equal(String(kCMTextMarkupGenericFontName_SmallCapital)))
                }
            }
        }
        
        // MARK: - TextStyle
        
        describe("TextStyle") {
            context(".characterBackground") {
                it("has ...") {
                    let style: TextStyle = .characterBackground(.white)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_CharacterBackgroundColorARGB) : [1.0, 1.0, 1.0, 1.0]])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_CharacterBackgroundColorARGB)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".background") {
                it("has...") {
                    let style: TextStyle = .background(.white)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_BackgroundColorARGB) : [1.0, 1.0, 1.0, 1.0]])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_BackgroundColorARGB)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".foreground") {
                it("") {
                    let style: TextStyle = .foreground(.red)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_ForegroundColorARGB) : [1.0, 1.0, 0, 0]])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_ForegroundColorARGB)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".fontSize") {
                it("") {
                    let style: TextStyle = .fontSize(12)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight) : 12])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".bold") {
                it("") {
                    let style: TextStyle = .bold
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_BoldStyle) : true])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_BoldStyle)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".underline") {
                it("") {
                    let style: TextStyle = .underline
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_UnderlineStyle) : true])
                    
                    expect(style.key).to(equal(String(kCMTextMarkupAttribute_UnderlineStyle)))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".italic") {
                it("") {
                    let style: TextStyle = .italic
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String(kCMTextMarkupAttribute_ItalicStyle) : true])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_ItalicStyle))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".edge") {
                it("") {
                    let style: TextStyle = .edge(.dropShadow)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_CharacterEdgeStyle)) : kCMTextMarkupCharacterEdgeStyle_DropShadow])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_CharacterEdgeStyle))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".alignment") {
                it("") {
                    let style: TextStyle = .alignment(.left)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_Alignment)) : (kCMTextMarkupAlignmentType_Left)])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_Alignment))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
            
            context(".direction") {
                it("") {
                    let style: TextStyle = .direction(.ltr)
                    let expectedValue = AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_VerticalLayout)) : (kCMTextVerticalLayout_LeftToRight)])
                    
                    expect(style.key).to(equal(String((kCMTextMarkupAttribute_VerticalLayout))))
                    expect(style.value).to(equal(expectedValue))
                }
            }
        }
        
        // MARK: - AVPlayerItem
        
        describe("AVPlayerItem") {
            context("textStyle") {
                it("") {
                    let currentItem = AVPlayerItem(url: URL(fileURLWithPath: ""))
                    currentItem.textStyle = [
                        .alignment(.left),
                        .background(.white),
                        .bold,
                        .characterBackground(.red),
                        .direction(.ltr),
                        .edge(.dropShadow),
                        .font(.casual),
                        .fontSize(12),
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
