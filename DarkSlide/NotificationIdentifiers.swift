//
//  NotificationIdentifiers.swift
//  DarkSlide
//
//  Created by Calum Harris on 13/12/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

struct NotificationIdentifiers {
	struct PhotoVideo {
		static let WillClosePreviewView: String = "WillClosePreviewView"
		static let SInterupted: String = "AVCaptureSessionWasInterruptedNotification"
		static let SInteruptionEnded: String = "AVCaptureSessionInterruptionEndedNotification"
		static let SubjectAreaDidChange: String = "AVCaptureDeviceSubjectAreaDidChangeNotification"
		static let SRuntimeError: String = "AVCaptureSessionRuntimeErrorNotification"
	}
}
