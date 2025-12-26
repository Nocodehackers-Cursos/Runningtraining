//
//  DateExtensions.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation

extension Date {
    /// Calcula el número de semanas completas desde esta fecha hasta otra fecha
    func weeksUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: self, to: date)
        return components.weekOfYear ?? 0
    }

    /// Calcula el número de días desde esta fecha hasta otra fecha
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }

    /// Devuelve el inicio de la semana (lunes) para esta fecha
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        components.weekday = 2 // 2 = Lunes en el calendario gregoriano
        return calendar.date(from: components) ?? self
    }

    /// Devuelve el día de la semana (1 = Lunes, 7 = Domingo)
    func dayOfWeek() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        // Convertir de formato Calendar (1 = Domingo) a nuestro formato (1 = Lunes)
        return weekday == 1 ? 7 : weekday - 1
    }

    /// Agrega un número de días a esta fecha
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Agrega un número de semanas a esta fecha
    func addingWeeks(_ weeks: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    /// Verifica si esta fecha es en el futuro
    var isInFuture: Bool {
        return self > Date()
    }

    /// Verifica si esta fecha es en el pasado
    var isInPast: Bool {
        return self < Date()
    }

    /// Verifica si esta fecha es hoy
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    /// Formatea la fecha como "dd MMM yyyy" (ej: "20 Dic 2025")
    func formattedShort() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }

    /// Formatea la fecha como "EEEE, dd MMMM" (ej: "Lunes, 20 Diciembre")
    func formattedLong() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, dd MMMM"
        return formatter.string(from: self)
    }
}
