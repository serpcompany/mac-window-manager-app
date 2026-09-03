/// CenterProminentlyCalculation.swift

import Foundation

class CenterProminentlyCalculation: WindowCalculation {
    
    override func calculate(_ params: WindowCalculationParameters) -> WindowCalculationResult? {
        
        let rectResult = calculateRect(params.asRectParams())
        
        let resultingAction: WindowAction = rectResult.resultingAction ?? params.action

        return WindowCalculationResult(rect: rectResult.rect,
                                       screen: params.usableScreens.currentScreen,
                                       resultingAction: resultingAction)
    }
    
    override func calculateRect(_ params: RectCalculationParameters) -> RectResult {
        
        let rectResult = WindowCalculationFactory.centerCalculation.calculateRect(params)
        var rect = rectResult.rect
        rect.origin.y += -0.25 * rect.height + 0.25 * params.visibleFrameOfScreen.height
        return RectResult(rect, resultingAction: rectResult.resultingAction)

    }
    
}
